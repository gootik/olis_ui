// Physical edges are shared by Sheet snap gestures and Drawer dismissal.
export const gestureAxis = (placement) => (["left", "right"].includes(placement) ? "X" : "Y");
export const gestureDirection = (placement) => (["top", "left"].includes(placement) ? -1 : 1);
