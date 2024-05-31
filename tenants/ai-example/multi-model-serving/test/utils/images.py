import cv2
import numpy as np
from PIL import Image, ImageColor, ImageDraw, ImageFont
import torch
import torchvision



def preprocess(image_path, scaled_image_size=640):
    image = cv2.imread(image_path)
    image, ratio, dwdh = _letterbox_image(image, scaled_image_size, auto=False)
    image = image.transpose((2, 0, 1))
    image = np.expand_dims(image, 0)
    image = np.ascontiguousarray(image)
    im = image.astype(np.float32)
    im /= 255
    return im, ratio, dwdh


def _letterbox_image(
        im, image_size, color=(114, 114, 114), auto=True, scaleup=True, stride=32):

    shape = im.shape[:2]
    new_shape = image_size
    if isinstance(new_shape, int):
        new_shape = (new_shape, new_shape)

    r = min(new_shape[0] / shape[0], new_shape[1] / shape[1])
    if not scaleup:
        r = min(r, 1.0)

    new_unpad = int(round(shape[1] * r)), int(round(shape[0] * r))
    dw, dh = new_shape[1] - new_unpad[0], new_shape[0] - new_unpad[1]

    if auto:
        dw, dh = np.mod(dw, stride), np.mod(dh, stride)

    dw /= 2
    dh /= 2

    if shape[::-1] != new_unpad:
        im = cv2.resize(im, new_unpad, interpolation=cv2.INTER_LINEAR)
    top, bottom = int(round(dh - 0.1)), int(round(dh + 0.1))
    left, right = int(round(dw - 0.1)), int(round(dw + 0.1))
    im = cv2.copyMakeBorder(
        im, top, bottom, left, right, cv2.BORDER_CONSTANT, value=color
    )

    return im, r, (dw, dh)


def postprocess(
        prediction,
        class_labels,
        conf_thres=0.2,
        iou_thres=0.6,
        max_det=300,
        nm=0,
):
    prediction = torch.Tensor(prediction)
    bs = prediction.shape[0]
    nc = prediction.shape[2] - nm - 5
    xc = prediction[..., 4] > conf_thres

    max_wh = 7680
    max_nms = 30000

    mi = 5 + nc
    output = [torch.zeros((0, 6 + nm), device=prediction.device)] * bs

    results = []

    for xi, x in enumerate(prediction):
        x = x[xc[xi]]

        if not x.shape[0]:
            continue

        x[:, 5:] *= x[:, 4:5]
        box = _xywh2xyxy(x[:, :4])
        mask = x[:, mi:]
        conf, j = x[:, 5:mi].max(1, keepdim=True)
        x = torch.cat((box, conf, j.float(), mask), 1)[
            conf.view(-1) > conf_thres
        ]

        n = x.shape[0]
        if not n:
            continue
        elif n > max_nms:
            x = x[x[:, 4].argsort(descending=True)[:max_nms]]
        else:
            x = x[x[:, 4].argsort(descending=True)]

        c = x[:, 5:6] * max_wh
        boxes = x[:, :4] + c
        scores = x[:, 4]
        i = torchvision.ops.nms(boxes, scores, iou_thres)
        if i.shape[0] > max_det:
            i = i[:max_det]

        output[xi] = x[i]

        final_boxes = np.array(output[xi][..., :4])
        final_boxes = final_boxes.round().astype(np.int32).tolist()
        cls_id = np.array(output[xi][..., 5], dtype=int)
        scores = np.array(output[xi][..., 4])
        names = [class_labels[id_] for id_ in cls_id]

        results.append([final_boxes, scores, names])

    return results


def _xywh2xyxy(x):
    y = torch.zeros_like(x) if isinstance(x, torch.Tensor) else np.zeros_like(x)
    y[:, 0] = x[:, 0] - x[:, 2] / 2
    y[:, 1] = x[:, 1] - x[:, 3] / 2
    y[:, 2] = x[:, 0] + x[:, 2] / 2
    y[:, 3] = x[:, 1] + x[:, 3] / 2
    return y


def _box_iou(box1, box2, eps=1e-7):
    (a1, a2), (b1, b2) = (
        box1.unsqueeze(1).chunk(2, 2),
        box2.unsqueeze(0).chunk(2, 2)
    )
    inter = (torch.min(a2, b2) - torch.max(a1, b1)).clamp(0).prod(2)
    return inter / ((a2 - a1).prod(2) + (b2 - b1).prod(2) - inter + eps)


def draw_boxes(image, boxes, scores, classes):
    """Overlay labeled boxes on an image with formatted scores and label names."""
    colors = list(ImageColor.colormap.values())
    class_colors = {}
    font = ImageFont.load_default()
    image_pil = Image.open(image)

    for index, class_ in enumerate(classes):
        box = boxes[index]
        display_str = f'{class_}: {int(100 * scores[index])}%'
        if class_ not in class_colors:
            class_colors[class_] = colors[hash(class_) * 8 % len(colors)]
        color = class_colors.get(class_)
        _draw_bounding_box_on_image(
            image_pil, box[0], box[1], box[2], box[3], color, font,
            display_str_list=[display_str]
        )
    return image_pil
    image_pil.show()


def _draw_bounding_box_on_image(
        image, xmin, ymin, xmax, ymax, color, font,
        thickness=4, display_str_list=()):
    """Adds a bounding box to an image."""
    draw = ImageDraw.Draw(image)
    im_width, im_height = image.size
    width_scaling_factor = im_width / 640
    height_scaling_factor = im_height / 640
    (left, right, top, bottom) = (
        xmin * width_scaling_factor,
        xmax * width_scaling_factor,
        ymin * height_scaling_factor,
        ymax * height_scaling_factor,
    )
    draw.line([(left, top), (left, bottom), (right, bottom), (right, top),
               (left, top)], width=thickness, fill=color)

    display_str_heights = [font.getbbox(ds)[3] for ds in display_str_list]
    total_display_str_height = (1 + 2 * 0.05) * sum(display_str_heights)
    if top > total_display_str_height:
        text_bottom = top
    else:
        text_bottom = top + total_display_str_height

    for display_str in display_str_list[::-1]:
        _, _, text_width, text_height = font.getbbox(display_str)
        margin = np.ceil(0.05 * text_height)
        draw.rectangle([(left, text_bottom - text_height - 2 * margin),
                        (left + text_width, text_bottom)], fill=color)
        draw.text((left + margin, text_bottom - text_height - margin),
                  display_str, fill="black", font=font)
        text_bottom -= text_height - 2 * margin

