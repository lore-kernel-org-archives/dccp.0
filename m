From: David Miller <davem@davemloft.net>
Date: Mon, 08 Dec 2008 09:16:04 +0000
Subject: Re: [PATCH 2/7] dccp: Integration of dynamic feature activation -
Message-Id: <20081208.011604.20334616.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1228581657-6724-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1228581657-6724-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat,  6 Dec 2008 17:40:52 +0100

> This patch integrates the activation of features at the end of negotiation
> into the server-side code.
> 
> Note regarding the removal of 'const':
> --------------------------------------
>  The 'const' attribute has been removed from 'dreq' since dccp_activate_values()
>  needs to operate on dreq's feature list. Part of the activation is to remove
>  those options from the list that have already been confirmed, hence it is not
>  purely read-only.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.
