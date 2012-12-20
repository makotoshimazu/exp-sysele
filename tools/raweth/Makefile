
CFLAGS = -g -O0 -W -Wall

RECV_SRCS = raweth.c recv.c 
RECV_OBJS = $(RECV_SRCS:.c=.o)

SEND_SRCS = raweth.c send.c
SEND_OBJS = $(SEND_SRCS:.c=.o)

RECV2_SRCS = raweth.c recv2.c
RECV2_OBJS = $(RECV2_SRCS:.c=.o)

.PHONY:all 
all: recv send recv2

recv: $(RECV_OBJS)
	$(CC) $(CFLAGS) -o $@ $^

send: $(SEND_OBJS)
	$(CC) $(CFLAGS) -o $@ $^

recv2: $(RECV2_OBJS)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<


clean:
	rm -f $(RECV_OBJS) recv $(SEND_OBJS) send $(RECV2_OBJS) recv2
