From: Julia Lawall <julia.lawall@lip6.fr>
Date: Tue, 02 Jan 2018 13:55:08 +0000
Subject: Re: [Cluster-devel] [PATCH 00/12] drop unneeded newline
Message-Id: <alpine.DEB.2.20.1801021454090.24055@hadrien>
List-Id: <dccp.vger.kernel.org>
References: <1878806802.2632123.1514901158666.JavaMail.zimbra@redhat.com>
In-Reply-To: <1878806802.2632123.1514901158666.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org



On Tue, 2 Jan 2018, Bob Peterson wrote:

> ----- Original Message -----
> | Drop newline at the end of a message string when the printing function adds
> | a newline.
>
> Hi Julia,
>
> NACK.
>
> As much as it's a pain when searching the source code for output strings,
> this patch set goes against the accepted Linux coding style document. See:
>
> https://www.kernel.org/doc/html/v4.10/process/coding-style.html#breaking-long-lines-and-strings

I don't think that's the case:

"However, never break user-visible strings such as printk messages,
because that breaks the ability to grep for them."

julia

>
> Regards,
>
> Bob Peterson
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
