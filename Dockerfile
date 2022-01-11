FROM ghcr.io/openfaas/classic-watchdog:0.1.4 as watchdog

FROM ubuntu:18.04 as solo5-builder

RUN apt update && apt install -y build-essential libseccomp-dev git pkg-config && apt-get clean

WORKDIR /

RUN git clone https://github.com/solo5/solo5

WORKDIR /solo5

RUN ./configure.sh && make
# build a static solo5-hvt binary

ARG ARCH=
RUN cd tenders && \
    cc  -Wl,-z -Wl,noexecstack -Wl,-z -Wl,noexecstack hvt/hvt_boot_info.o hvt/hvt_core.o hvt/hvt_main.o hvt/hvt_cpu_$ARCH.o hvt/hvt_kvm.o hvt/hvt_kvm_$ARCH.o hvt/hvt_module_blk.o hvt/hvt_module_net.o common/libcommon.a  -lseccomp -o hvt/solo5-hvt -static
    

FROM alpine as builder
COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog


COPY --from=solo5-builder /solo5/tenders/hvt/solo5-hvt /solo5-hvt
COPY --from=solo5-builder /solo5/tests/test_hello/test_hello.hvt .

EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

ENV write_debug="true"
ENV fprocess="xargs ./solo5-hvt --mem=2 test_hello.hvt"
CMD ["fwatchdog"]
