From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Oct 2007 18:10:47 +0000
Subject: Re: [PATCH v3 4/9]: Resolve dependencies of features on choice of CCID
Message-Id: <5640c7e00710031110g2db19c39jab3dc3774f56f907@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710030945.53328@strip-the-willow>
In-Reply-To: <200710030945.53328@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/3/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Reworked patch, updated as requested:
>  * removed `typedef const'
>  * made all initialisation explicit, using field initialisers
>    This increases the space somewhat, but indeed much better readability.
>  * Ian I have added your Acked-by as requested, but please have another look and let me know
>    whether you are ok with this revision
>
I'm OK with this revision.
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
