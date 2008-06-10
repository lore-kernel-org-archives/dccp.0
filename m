From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 10 Jun 2008 09:05:50 +0000
Subject: Re: [PATCH] DCCP: Initialize ireq6->pktopts before used it
Message-Id: <484E43EE.60406@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
References: <484E42BE.9020408@cn.fujitsu.com>
In-Reply-To: <484E42BE.9020408@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

I think I should add dccp_v6_reqsk_init() do to the init work since=20
dccp_reqsk_init may be fail too.

Wei Yongjun wrote:
> ireq6->pktopts is not initialized after dccp_reqsk_init(), and it will=20
> be free in dccp_v6_reqsk_destructor(), so if dccp_parse_options() is=20
> fail, this may cause kernel panic since ireq6->pktopts is not=20
> initialized.
>
> This patch fix this problem by initialize ireq6->pktopts before used it.
>
> static void dccp_v6_reqsk_destructor(struct request_sock *req)
> {
>        dccp_feat_list_purge(&dccp_rsk(req)->dreq_featneg);
>        if (inet6_rsk(req)->pktopts !=3D NULL)
>                kfree_skb(inet6_rsk(req)->pktopts);
> }
>
> Pid: 0, comm: swapper Not tainted (2.6.26-rc2 #1)
> EIP: 0060:[<c05acdaf>] EFLAGS: 00010206 CPU: 0
> EIP is at kfree_skb+0x9/0x30
> EAX: 00002fde EBX: c7306e80 ECX: c7801080 EDX: 00002fde
> ESI: c7983680 EDI: c72d9800 EBP: c075adfc ESP: c075adfc
> DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process swapper (pid: 0, ti=C075a000 task=C06df3a0 task.ti=C0714000)
> Stack: c075ae08 c8a259d8 c7a0f848 c075ae38 c8a260fc c7983680 c72d9800=20
> c72d9b90
>      64000000 c79836a0 c7306e80 8cf2437f c7a0f848 c7983680 c72d9800=20
> c075ae78
>      c89e6c78 c7983680 c72d9800 0a804500 c79836a0 0c011908 f24206cc=20
> c46c3660
> Call Trace:
> [<c8a259d8>] ? dccp_v6_reqsk_destructor+0x1f/0x22 [dccp_ipv6]
> [<c8a260fc>] ? dccp_v6_conn_request+0x243/0x27d [dccp_ipv6]
> [<c89e6c78>] ? dccp_rcv_state_process+0x3d/0x4b5 [dccp]
> [<c8a25976>] ? dccp_v6_do_rcv+0x132/0x175 [dccp_ipv6]
> [<c05bb355>] ? sk_filter+0x66/0x6d
> [<c05ab5c2>] ? sk_receive_skb+0x32/0x7c
> [<c8a267b3>] ? dccp_v6_rcv+0x2a5/0x32a [dccp_ipv6]
> [<c8ee2ee0>] ? ip6_input_finish+0x158/0x280 [ipv6]
> [<c8ee304a>] ? ip6_input+0x42/0x47 [ipv6]
> [<c8ee3357>] ? ipv6_rcv+0x27c/0x2c9 [ipv6]
> [<c05b1336>] ? netif_receive_skb+0x2e0/0x349
> [<c88f2a12>] ? pcnet32_poll+0x333/0x66e [pcnet32]
> [<c0438afa>] ? clocksource_watchdog+0x21e/0x22d
> [<c040428b>] ? common_interrupt+0x23/0x28
> [<c05b308c>] ? net_rx_action+0x8f/0x147
> [<c0427c5b>] ? __do_softirq+0x64/0xcd
> [<c0405898>] ? do_softirq+0x55/0x88
> [<c0427bf5>] ? irq_exit+0x38/0x3a
> [<c0412b42>] ? smp_apic_timer_interrupt+0x71/0x7f
> [<c04025eb>] ? default_idle+0x0/0x42
> [<c0404348>] ? apic_timer_interrupt+0x28/0x30
> [<c04025eb>] ? default_idle+0x0/0x42
> [<c0402618>] ? default_idle+0x2d/0x42
> [<c0402566>] ? cpu_idle+0x8b/0x9f
> [<c060c89a>] ? rest_init+0x4e/0x50
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D>
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
>
> --- a/net/dccp/ipv6.c    2008-05-29 22:27:55.000000000 -0400
> +++ b/net/dccp/ipv6.c    2008-06-05 05:58:00.000000000 -0400
> @@ -413,6 +413,9 @@ static int dccp_v6_conn_request(struct s
>     if (dccp_reqsk_init(req, dccp_sk(sk), skb))
>         goto drop_and_free;
>
> +    ireq6 =3D inet6_rsk(req);
> +    ireq6->pktopts    =3D NULL;
> +
>     dreq =3D dccp_rsk(req);
>     if (dccp_parse_options(sk, dreq, skb))
>         goto drop_and_free;
> @@ -420,10 +423,8 @@ static int dccp_v6_conn_request(struct s
>     if (security_inet_conn_request(sk, skb, req))
>         goto drop_and_free;
>
> -    ireq6 =3D inet6_rsk(req);
>     ipv6_addr_copy(&ireq6->rmt_addr, &ipv6_hdr(skb)->saddr);
>     ipv6_addr_copy(&ireq6->loc_addr, &ipv6_hdr(skb)->daddr);
> -    ireq6->pktopts    =3D NULL;
>
>     if (ipv6_opt_accepted(sk, skb) ||
>         np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
>
>
> --=20
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>


--=20
--------------------------------------------------
Wei Yongjun
Development Dept.I
Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
8/F., Civil Defense Building, No.189 Guangzhou Road,
Nanjing, 210029, China
TEL: +86+25-86630523-836
COINS: 79955-836
FAX: +86+25-83317685
MAIL: yjwei@cn.fujitsu.com
--------------------------------------------------
This communication is for use by the intended recipient(s) only and may con=
tain information that is privileged, confidential and exempt from disclosur=
e under applicable law. If you are not an intended recipient of this commun=
ication, you are hereby notified that any dissemination, distribution or co=
pying hereof is strictly prohibited.  If you have received this communicati=
on in error, please notify me by reply e-mail, permanently delete this comm=
unication from your system, and destroy any hard copies you may have printed

