From: Ian McDonald <imcdnzl@gmail.com>
Date: Tue, 24 Jan 2006 23:32:20 +0000
Subject: Re: service code bug in linux & tcpdump
Message-Id: <cbec11ac0601241532h4242fd64p4b171f6d678f909@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20060124111016.GA1159@tribal.sorbonet.org>
In-Reply-To: <20060124111016.GA1159@tribal.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>  > did tcpdump get it wrong then?
>  > print-dccp.c:315
>  >
>  > (void)printf("request (service=%d) ", dhr->dccph_req_service);
>  >
>  > should that be EXTRACT_32BITS(&dhr->dccph_req_service) ?
>
Feel free to submit to tcpdump workers list which is how I got the
code merged.... otherwise I will look at some time when I have time
(not soon!) as there are a couple of other DCCP bugs for tcpdump as
well....
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
University of Waikato
New Zealand
