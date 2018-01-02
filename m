From: Julia Lawall <julia.lawall@lip6.fr>
Date: Tue, 02 Jan 2018 14:00:46 +0000
Subject: Re: [Cluster-devel] [PATCH 00/12] drop unneeded newline
Message-Id: <alpine.DEB.2.20.1801021458360.24055@hadrien>
List-Id: <dccp.vger.kernel.org>
References: <1878806802.2632123.1514901158666.JavaMail.zimbra@redhat.com>
In-Reply-To: <1878806802.2632123.1514901158666.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org



On Tue, 2 Jan 2018, Bob Peterson wrote:

> ----- Original Message -----
> | ----- Original Message -----
> | | Drop newline at the end of a message string when the printing function adds
> | | a newline.
> |
> | Hi Julia,
> |
> | NACK.
> |
> | As much as it's a pain when searching the source code for output strings,
> | this patch set goes against the accepted Linux coding style document. See:
> |
> | https://www.kernel.org/doc/html/v4.10/process/coding-style.html#breaking-long-lines-and-strings
> |
> | Regards,
> |
> | Bob Peterson
> |
> |
> Hm. I guess I stand corrected. The document reads:
>
> "However, never break user-visible strings such as printk messages, because that breaks the ability to grep for them."
>
> Still, the GFS2 and DLM code has a plethora of broken-up printk messages,
> and I don't like the thought of re-combining them all.

Actually, the point of the patch was to remove the unnecessary \n at the
end of the string, because log_print will add another one.  If you prefer
to keep the string broken up, I can resend the patch in that form, but
without the unnecessary \n.

julia
