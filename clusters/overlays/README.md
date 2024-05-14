# Cluster Overlays

This folder contains some example cluster overlays that correspond to the OpenShift AI operator channel. 

For example, the `eus-2.8` folder contains the Extended User Support 2.8 version of RHOAI. See the [official life cycle docs](https://access.redhat.com/support/policy/updates/rhoai-sm/lifecycle) for more information about EUS and support policies.

At time of writing, EUS releases will be supported for 18 months and every 9 (ish) releases will be EUS. So 2.8 is the only current EUS release and 2.16 is planned to be the next EUS release.

The RHOAI development team also targets a minor release every month or so that will be available on the `fast` channel. Fast releases are only supported if you keep current.

Every 3 releases will be a stable release and supported for 7 months.  2.10 will be the next stable release.

We plan to maintain working examples for `EUS`, `Stable`, and `fast` within this folder.