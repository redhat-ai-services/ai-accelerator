# generate generation_pb2_grpc.py using:
#
#   python -m grpc_tools.protoc -I proto --python_out=. --pyi_out=. --grpc_python_out=. path/to/text-generation-inference/proto/generation.proto
#
# get the protos from https://github.com/opendatahub-io/text-generation-inference/

from typing import Optional, Union

import grpc
import generation_pb2_grpc
import socket
import ssl
import sys


def get_server_certificate(host: str, port: int) -> str:
    """connect to host:port and get the certificate it presents

    This is almost the same as `ssl.get_server_certificate`, but
    when opening the TLS socket, `server_hostname` is also provided.

    This retrieves the correct certificate for hosts using name-based
    virtual hosting.
    """
    if sys.version_info >= (3, 10):
        # ssl.get_server_certificate supports TLS SNI only above 3.10
        # https://github.com/python/cpython/pull/16820
        return ssl.get_server_certificate((host, port))

    context = ssl.SSLContext()

    with socket.create_connection((host, port)) as sock, context.wrap_socket(
        sock, server_hostname=host
    ) as ssock:
        cert_der = ssock.getpeercert(binary_form=True)

    assert cert_der
    return ssl.DER_cert_to_PEM_cert(cert_der)


class TgisGrpcClient:
    def __init__(
        self,
        host: str,
        port: int,
        *,
        insecure: bool = False,
        verify: Optional[bool] = None,
        ca_cert: Union[None, bytes, str] = None,
        client_cert: Union[None, bytes, str] = None,
        client_key: Union[None, bytes, str] = None,
    ) -> None:
        self._channel = self._make_channel(
            host,
            port,
            insecure=insecure,
            verify=verify,
            client_key=client_key,
            client_cert=client_cert,
            ca_cert=ca_cert,
        )
        self.generation_service_stub = generation_pb2_grpc.GenerationServiceStub(
            self._channel
        )

    def make_request(self, text: str, model_id: str = "flan-t5-small"):
        request = generation_pb2_grpc.generation__pb2.BatchedGenerationRequest(
            model_id=model_id,
            requests=[generation_pb2_grpc.generation__pb2.GenerationRequest(text=text)],
        )
        result = self.generation_service_stub.Generate(request=request)
        print(result)
        return result

    def __enter__(self):
        return self

    def __exit__(self, *exc_info):
        self._close()
        return False

    def _close(self):
        try:
            if hasattr(self, "_channel") and self._channel:
                self._channel.close()
        except Exception as exc:
            print(f"Unexpected exception while closing client: {exc}")

    def __del__(self):
        self._close()

    def _make_channel(
        self,
        host: str,
        port: int,
        *,
        insecure: bool = False,
        verify: Optional[bool] = None,
        ca_cert: Union[None, bytes, str] = None,
        client_key: Union[None, bytes, str] = None,
        client_cert: Union[None, bytes, str] = None,
    ) -> grpc.Channel:
        """Creates a grpc channel

        Args:
        - host: str
        - port: str
        - (optional) insecure: use a plaintext connection (default=False)
        - (optional) verify: set to False to disable remote host certificate(s)
                     verification. Cannot be used with `plaintext` or with MTLS
        - (optional) ca_cert: certificate authority to use
        - (optional) client_key: client key for mTLS mode
        - (optional) client_cert: client cert for mTLS mode

        """
        if not host.strip():
            raise ValueError("A non empty host name is required")
        if int(port) <= 0:
            raise ValueError("A non zero port number is required")
        if insecure and any(
            (val is not None) for val in (ca_cert, client_key, client_cert)
        ):
            raise ValueError("cannot use insecure with TLS/mTLS certificates")
        if insecure and verify:
            raise ValueError("insecure cannot be used with verify")

        client_key_bytes = self._try_load_certificate(client_key)
        client_cert_bytes = self._try_load_certificate(client_cert)
        ca_cert_bytes = self._try_load_certificate(ca_cert)

        connection = f"{host}:{port}"
        if insecure:
            print("Connecting over an insecure plaintext grpc channel")
            return grpc.insecure_channel(connection)

        credentials_kwargs: dict[str, bytes] = {}
        if ca_cert_bytes and not (any((client_cert_bytes, client_key_bytes))):
            print("Connecting using provided CA certificate for secure channel")
            credentials_kwargs.update(root_certificates=ca_cert_bytes)
        elif client_cert_bytes and client_key_bytes and ca_cert_bytes:
            print("Connecting using mTLS for secure channel")
            credentials_kwargs.update(
                root_certificates=ca_cert_bytes,
                private_key=client_key_bytes,
                certificate_chain=client_cert_bytes,
            )
        elif verify is False:
            print(
                f"insecure mode: trusting remote certificate from {host}:{port}",
            )

            cert = get_server_certificate(host, port).encode()
            credentials_kwargs.update(root_certificates=cert)

        return grpc.secure_channel(
            connection, grpc.ssl_channel_credentials(**credentials_kwargs)
        )

    @staticmethod
    def _try_load_certificate(certificate: Union[None, bytes, str]) -> Optional[bytes]:
        """If the certificate points to a file, return the contents (plaintext reads).
        Else return the bytes"""
        if not certificate:
            return None

        if isinstance(certificate, bytes):
            return certificate

        if isinstance(certificate, str):
            with open(certificate, "rb") as secret_file:
                return secret_file.read()
        raise ValueError(
            f"{certificate=} should be a path to a certificate files or bytes"
        )
