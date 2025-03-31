select * from {{ source("dts_rts_interview", "e_extract_udp_srf") }}
--renommage, retypage