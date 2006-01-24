From: Yoshifumi Nishida <nishida@csl.sony.co.jp>
Date: Tue, 24 Jan 2006 14:24:29 +0000
Subject: Re: service code bug in linux & tcpdump
Message-Id: <20060124.232429.71568571.nishida@csl.sony.co.jp>
List-Id: <dccp.vger.kernel.org>
References: <20060124111016.GA1159@tribal.sorbonet.org>
In-Reply-To: <20060124111016.GA1159@tribal.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Subject: Re: service code bug in linux & tcpdump
Date: Tue, 24 Jan 2006 11:37:15 +0000
Message-ID: <20060124113715.GA1953@tribal.sorbonet.org>

 > On Tue, Jan 24, 2006 at 08:22:56PM +0900, Yoshifumi Nishida wrote:
 > > I believe applications should do htonl(), like port number.
 > 
 > did tcpdump get it wrong then?
 > print-dccp.c:315
 > 
 > (void)printf("request (service=%d) ", dhr->dccph_req_service);
 > 
 > should that be EXTRACT_32BITS(&dhr->dccph_req_service) ?

In my opinion, yes.

Thanks,
--
Yoshifumi Nishida
nishida@csl.sony.co.jp
