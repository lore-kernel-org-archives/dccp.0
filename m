From: "Eugene Teo" <eugeneteo@kernel.sg>
Date: Fri, 29 Aug 2008 09:25:53 +0000
Subject: Re: [PATCH 14/37] dccp: Tidy up setsockopt calls
Message-Id: <28fa9c5e0808290225w1d2a2ff7kf4fb63741780c091@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-15-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-15-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Aug 29, 2008 at 1:44 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
[...]
> +       default:
> +               if (optlen < sizeof(int))
> +                       return -EINVAL;

Although it is already checked in sys_setsockopt(), it's probably good
to change this to:

               if (optlen < (int)sizeof(int))
                       return -EINVAL;

Reviewed-by: Eugene Teo <eugeneteo@kernel.sg>

Thanks, Eugene
