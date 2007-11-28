From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 28 Nov 2007 14:13:22 +0000
Subject: Re: [PATCH 4/4]: Remove duplicate test for CloseReq
Message-Id: <20071128141321.GD25255@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <11962389121810-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11962389121810-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Nov 28, 2007 at 08:35:11AM +0000, Gerrit Renker escreveu:
> [DCCP]: Remove duplicate test for CloseReq
> 
> This removes a redundant test for unexpected packet types. In dccp_rcv_state_process
> it is tested twice whether a DCCP-server has received a CloseReq (Step 7):
> 
>  * first in the combined if-statement,
>  * then in the call to dccp_rcv_closereq().
> 
> The latter is necesssary since dccp_rcv_closereq() is also called from
> __dccp_rcv_established().
> 
> This patch removes the duplicate test.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Thanks, applied.

- Arnaldo
