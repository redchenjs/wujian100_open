OBJDIR = $(shell pwd)/obj
SRCDIR = $(shell pwd)/../wujian100_open-boot/src/mbedtls

INC = \
        -I$(shell pwd) \
        -I$(SRCDIR)/include \

SRC = \
        $(SRCDIR)/library/*.c \

EXT = $(wildcard $(SRC))
OBJ = $(EXT:%.c=%.o)

CFLAGS += $(INC) -Wall

all: dir $(OBJ)
	@echo LD mkflash
	@$(CC) mkflash.c -o mkflash
	@echo LD rsa_sign
	@$(CC) $(CFLAGS) $(OBJDIR)/*.o rsa_sign.c -o rsa_sign
	@echo LD rsa_verify
	@$(CC) $(CFLAGS) $(OBJDIR)/*.o rsa_verify.c -o rsa_verify

dir:
	@mkdir -p $(OBJDIR)

%.o: %.c
	@echo CC ${shell echo $<|awk -F '/' '{print $$NF}'}
	@$(CC) $(CFLAGS) -o $(OBJDIR)/${shell echo $@|awk -F '/' '{print $$NF}'} -c $<

clean:
	@echo RM mkflash
	@$(RM) -f mkflash
	@echo RM rsa_sign
	@$(RM) -f rsa_sign
	@echo RM rsa_verify
	@$(RM) -f rsa_verify
	@$(RM) -f flash.bin
	@$(RM) -rf $(OBJDIR)
