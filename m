From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 02 Oct 2007 18:48:39 +0000
Subject: Re: [PATCH 6/11]: Insert feature-negotiation options into skb
Message-Id: <5640c7e00710021148k31d1615cq4c169ee0af7ab990@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710011518.24129@strip-the-willow>
In-Reply-To: <200710011518.24129@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/3/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Revised patch following suggestions on the list.
> Changes:
>  * now uses constant to allocate space for variable-length option (nn_in_nbo[DCCP_OPTVAL_MAXLEN])
>  * added a hunk which referenced the function dccp_insert_options_feat() which is replaced by this
>    patch so that the patch can be compiled standalone
>  * updates in coding style (but that has been done for all other patches also)
>
> -------------------------> Patch v2 <-----------------------------------------------------------
> [DCCP]: Insert feature-negotiation options into skb
>
> The core insertion routine, provided by this patch, does a simple list walk and calls
> an already existing function in options.c to do the actual insertion of individual options.
>
> This replaces the earlier insertion routine from options.c
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
