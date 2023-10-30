#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

#define SERIAL_PORT "/dev/ttyUSB0"
#define BAUDRATE B9600

int main() {
    int serial_fd;
    struct termios oldtio, newtio;

    // シリアルポートを開く
    serial_fd = open(SERIAL_PORT, O_RDWR | O_NOCTTY);
    if (serial_fd < 0) {
        perror("Failed to open serial port");
        return -1;
    }

    // 現在のシリアルポートの設定を取得
    tcgetattr(serial_fd, &oldtio);

    // 新しい設定を行う
    newtio = oldtio;
    cfsetispeed(&newtio, BAUDRATE);
    cfsetospeed(&newtio, BAUDRATE);
    newtio.c_cflag &= ~CSIZE;
    newtio.c_cflag |= CS8;
    newtio.c_cflag &= ~PARENB;
    newtio.c_cflag &= ~CSTOPB;
    newtio.c_cflag &= ~CRTSCTS;
    newtio.c_cflag |= CREAD | CLOCAL;
    newtio.c_iflag &= ~(IXON | IXOFF | IXANY);
    newtio.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
    newtio.c_oflag &= ~OPOST;

    // シリアルポートの設定を適用
    tcsetattr(serial_fd, TCSANOW, &newtio);

    // データの送受信サンプル
    char send_data[] = "A"; // ASCII CODE 0x41 (0100 0001)
    write(serial_fd, send_data, strlen(send_data));

    char recv_data[256];
    int n = read(serial_fd, recv_data, sizeof(recv_data) - 1);
    if (n > 0) {
        recv_data[n] = '\0';
        printf("Received: %s\n", recv_data);
    }

    // シリアルポートをクローズ
    close(serial_fd);

    return 0;
}
