From: Eric Paris <eparis@parisplace.org>
Date: Sat, 11 Nov 2006 15:46:34 +0000
Subject: Re: [PATCH RFC] SELinux support for DCCP
Message-Id: <1163259994.12271.17.camel@localhost.localdomain>
List-Id: <dccp.vger.kernel.org>
References: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
In-Reply-To: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Sat, 2006-11-11 at 02:16 -0500, James Morris wrote:
> +
> +#define CONTEXT__TRANSLATE                        0x00000001UL
> +#define CONTEXT__CONTAINS                         0x00000002UL
> +  

> @@ -252,3 +256,7 @@
>     S_(SECCLASS_KEY, KEY__LINK, "link")
>     S_(SECCLASS_KEY, KEY__SETATTR, "setattr")
>     S_(SECCLASS_KEY, KEY__CREATE, "create")
> +   S_(SECCLASS_CONTEXT, CONTEXT__TRANSLATE, "translate")
> +   S_(SECCLASS_CONTEXT, CONTEXT__CONTAINS, "contains")
> +   S_(SECCLASS_DCCP_SOCKET, DCCP_SOCKET__NODE_BIND, "node_bind")
> +   S_(SECCLASS_DCCP_SOCKET, DCCP_SOCKET__NAME_CONNECT, "name_connect")


> diff -purN -X dontdiff linux-2.6.o/security/selinux/include/class_to_string.h linux-2.6.w/security/selinux/include/class_to_string.h
> --- linux-2.6.o/security/selinux/include/class_to_string.h	2006-09-23 23:33:32.000000000 -0400
> +++ linux-2.6.w/security/selinux/include/class_to_string.h	2006-11-11 00:29:49.000000000 -0500
> @@ -61,3 +61,5 @@
>      S_("appletalk_socket")
>      S_("packet")
>      S_("key")
> +    S_("context")
> +    S_("dccp_socket")


> diff -purN -X dontdiff linux-2.6.o/security/selinux/include/flask.h linux-2.6.w/security/selinux/include/flask.h
> --- linux-2.6.o/security/selinux/include/flask.h	2006-09-23 23:33:32.000000000 -0400
> +++ linux-2.6.w/security/selinux/include/flask.h	2006-11-11 00:28:31.000000000 -0500
> @@ -63,6 +63,8 @@
>  #define SECCLASS_APPLETALK_SOCKET                        56
>  #define SECCLASS_PACKET                                  57
>  #define SECCLASS_KEY                                     58
> +#define SECCLASS_CONTEXT                                 59
> +#define SECCLASS_DCCP_SOCKET                             60


What are the SECCLASS_CONTEXT, CONTEXT__CONTAINS, and CONTEXT__TRANSLATE
changes?

-Eric

