FROM alpine:latest

RUN apk add openssl

WORKDIR /home/aes_debug

COPY aes_bench_from_list.sh ./
COPY aes_algorithms.txt ./

CMD ["./aes_bench_from_list.sh"]
