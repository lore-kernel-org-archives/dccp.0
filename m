From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 22 Sep 2007 14:41:12 +0000
Subject: tcpdump broken wrt CsCov & CsVal parsing?
Message-Id: <20070922144111.GE10051@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Trying to rebuild a proper test setup, so far using just loopback for
simple tests I noticed this problem:

11:57:47.463084 IP localhost.40343 > localhost.5001: CCVal 0, CsCov 5, cksum 0xf52a (correct), dataack (ack5231163474841)
11:57:47.463095 IP localhost.5001 > localhost.40343: CCVal 0, CsCov 5, cksum 0x92f7 (correct), ack (ack5230668497611)
11:57:47.463219 IP localhost.40343 > localhost.5001: CCVal 0, CsCov 10, cksum 0xe8d8 (correct), dataack (ack5231163474842)
11:57:47.463231 IP localhost.5001 > localhost.40343: CCVal 0, CsCov 10, cksum 0xa7e9 (correct), ack (ack5230668497612)
11:57:47.463344 IP localhost.40343 > localhost.5001: CCVal 0, CsCov 15, cksum 0xda86 (correct), dataack (ack5231163474843)
11:57:47.463355 IP localhost.5001 > localhost.40343: CCVal 0, CsCov 15, cksum 0x166c (correct), ack (ack5230668497613)
11:57:47.463466 IP localhost.40343 > localhost.5001: CCVal 0, CsCov 4, cksum 0xcf34 (correct), dataack (ack5231163474844)
11:57:47.463477 IP localhost.5001 > localhost.40343: CCVal 0, CsCov 4, cksum 0x4f19 (correct), ack (ack5230668497614)

Who was the last person to touch the DCCP support code in tcpdump? Care
to take a look?

- Arnaldo
