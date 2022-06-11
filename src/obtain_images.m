cam = ipcam('http://localhost:1111/video.mjpg', 'root', 'Vivotek2');
cap = snapshot(cam);
figure, imshow(cap);
imwrite(cap, '../in_img/vivotek/mid_day/WTG38N.png')

cam = ipcam('http://localhost:1112/video.mjpg', 'root', 'Vivotek3');
cap = snapshot(cam);
figure, imshow(cap);
imwrite(cap, '../in_img/vivotek/mid_day/V01KHQ.png')

cam = ipcam('http://localhost:1113/video.mjpg', 'root', 'Vivotek4');
cap = snapshot(cam);
figure, imshow(cap);
imwrite(cap, '../in_img/vivotek/mid_day/T67YVU.png')