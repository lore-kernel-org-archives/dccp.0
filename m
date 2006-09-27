From: Vladimir M <vladivm@mail.ru>
Date: Wed, 27 Sep 2006 11:56:54 +0000
Subject: Sequence numbers in Response packets (Linux 2.6.17)
Message-Id: <E1GSY22-000OxT-00.vladivm-mail-ru@f75.mail.ru>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


Hi,

While doing some tresting, I've noticed a funny behaviour of DCCP implementation in 2.6 kernel. From Ethereal capture seems that retransmitted response packets do not increment the sequence number. Is it a correct behaviour? If yes, then why is it done like this, since protocol's RFC instructs to increment on every outgoing packet. 

B.R.
Vladimir.

P.S. Don't know, it it has been already discussed on the list or not, or even patched. I have original DCCP version from 2.6.17 FC5, but havnt found anything related in archives of this list
