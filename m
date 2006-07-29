From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 29 Jul 2006 20:43:41 +0000
Subject: Fwd: dccp: dead code?
Message-Id: <5640c7e00607291343j12227f90u44e3cf8148e22e23@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Should have replied to list as well...

---------- Forwarded message ----------
From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Jul 30, 2006 8:41 AM
Subject: Re: dccp: dead code?
To: Venkat Yekkirala <vyekkirala@trustedcs.com>


On 7/27/06, Venkat Yekkirala <vyekkirala@trustedcs.com> wrote:
> Hi,
>
> I am trying to figure out where/when dccp_v4_reqsk_send_ack and
> dccp_v6_reqsk_send_ack
> set to request_sock_ops.send_ack are being invoked. Or are these leftover
> dead code?
>
> Thanks,
>
> venkat
> -
it gets mapped into dccp_v4/6_prot.rsk_prot in the proto struct and
this gets registered so will get used as a callback function from
there.

Ian
--
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand


-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
