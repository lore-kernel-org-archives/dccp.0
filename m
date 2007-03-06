From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 06 Mar 2007 02:30:13 +0000
Subject: Re: CCID 3 bounded by OS scheduling granularity
Message-Id: <5640c7e00703051830v468f0bbdic1ad6c301e950145@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701221424.36105@strip-the-willow>
In-Reply-To: <200701221424.36105@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 1/23/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I have performed experiments which confirm that
>
>  1) when t_ipi < t_gran, the transmit rate is effectively out of control
>  2) when t_ipi > t_gran, the actual transmit rate is about a factor of 3
>     higher than s/t_ipi would permit.
>
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/packet_scheduling/

I've been going over this and wonder if you ever got to the bottom of
it by instrumenting it or similar as it doesn't make sense to me....
We add t_ipi to t_nom after each packet so even coarse grained
scheduling shouldn't do this.

Ian

-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
