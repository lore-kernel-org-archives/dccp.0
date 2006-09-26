From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 26 Sep 2006 20:49:06 +0000
Subject: Compile warnings in DCCP
Message-Id: <20060926134906.688c32f7@freekitty>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

OSDL does automated cross-builds.

*********ia64*********

> net/dccp/ccids/ccid2.c: In function `ccid2_hc_tx_packet_sent':
> net/dccp/ccids/ccid2.c:355: warning: long long unsigned int format, u64 arg (arg 3)
> net/dccp/ccids/ccid2.c:360: warning: long long unsigned int format, u64 arg (arg 3)
> net/dccp/ccids/ccid2.c: In function `ccid2_new_ack':
> net/dccp/ccids/ccid2.c:482: warning: long long unsigned int format, u64 arg (arg 5)
> net/dccp/ccids/ccid2.c: In function `ccid2_hc_tx_packet_recv':
> net/dccp/ccids/ccid2.c:639: warning: long long unsigned int format, u64 arg (arg 3)
> net/dccp/ccids/ccid2.c:639: warning: long long unsigned int format, u64 arg (arg 4)
> net/dccp/ccids/ccid2.c:674: warning: long long unsigned int format, u64 arg (arg 3)
> net/dccp/ccids/ccid2.c:720: warning: long long unsigned int format, u64 arg (arg 3)  


*********powerpc*********

> net/dccp/ccids/ccid2.c: In function 'ccid2_hc_tx_packet_sent':
> net/dccp/ccids/ccid2.c:355: warning: format '%llu' expects type 'long long unsigned int', but argument 3 has type 'u64'
> net/dccp/ccids/ccid2.c:360: warning: format '%llu' expects type 'long long unsigned int', but argument 3 has type 'u64'
> net/dccp/ccids/ccid2.c: In function 'ccid2_new_ack':
> net/dccp/ccids/ccid2.c:482: warning: format '%llu' expects type 'long long unsigned int', but argument 5 has type 'u64'
> net/dccp/ccids/ccid2.c: In function 'ccid2_hc_tx_packet_recv':
> net/dccp/ccids/ccid2.c:639: warning: format '%llu' expects type 'long long unsigned int', but argument 3 has type 'u64'
> net/dccp/ccids/ccid2.c:639: warning: format '%llu' expects type 'long long unsigned int', but argument 4 has type 'u64'
> net/dccp/ccids/ccid2.c:674: warning: format '%llu' expects type 'long long unsigned int', but argument 3 has type 'u64'
> net/dccp/ccids/ccid2.c:720: warning: format '%llu' expects type 'long long unsigned int', but argument 3 has type 'u64'  

-- 
Stephen Hemminger <shemminger@osdl.org>
