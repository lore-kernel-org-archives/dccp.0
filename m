From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 12 Jan 2007 20:02:39 +0000
Subject: Re: [PATCH 1/1] DCCP: Fix up t_nom - FOLLOW-UP
Message-Id: <5640c7e00701121202j62abc3b1s69b9ad64d183e900@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701101021.38920@strip-the-willow>
In-Reply-To: <200701101021.38920@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 13/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I have a snapshot which illustrates this state:
>
>  http://www.erg.abdn.ac.uk/users/gerrit/dccp/dccp_probe/examples/no_tx_locking/transmit_rate.png
>
> The oscillating behaviour is well visible. In contrast, I am sure that you would agree that the
> desirable state is the following:
>
>  http://www.erg.abdn.ac.uk/users/gerrit/dccp/dccp_probe/examples/with_tx_locking/transmit_rate.png
>

Questions on the graphs:
- are these direct connect nodes?
- why is Xcalc 0?
- why on the stable one is Xrecv different from X. Is X the rate that
it is allowed to send at but doesn't so only achieves Xrecv?
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
