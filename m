From: Yoshifumi Nishida <nishida@csl.sony.co.jp>
Date: Tue, 24 Jan 2006 11:22:56 +0000
Subject: Re: service code bug in linux & tcpdump
Message-Id: <20060124.202256.02085477.nishida@csl.sony.co.jp>
List-Id: <dccp.vger.kernel.org>
References: <20060124111016.GA1159@tribal.sorbonet.org>
In-Reply-To: <20060124111016.GA1159@tribal.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Subject: service code bug in linux & tcpdump
Date: Tue, 24 Jan 2006 11:10:16 +0000
Message-ID: <20060124111016.GA1159@tribal.sorbonet.org>

 > shouldn't the service code [u32] be in network byte order?
 > 
 > If so, linux:
 > net/dccp/output.c:105
 > should have a htonl();

I believe applications should do htonl(), like port number.

--
Yoshifumi Nishida
nishida@csl.sony.co.jp

