CREATE EXTERNAL TABLE `prj-faiqabahra-rts-interview.dts_rts_interview.e_extract_udp_srf`
  OPTIONS (
    format ="CSV",
    uris = ['gs://bkt_faiqabahra_rts_interview_raw/extract udp srf.csv']
    );