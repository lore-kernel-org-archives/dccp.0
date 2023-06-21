From: Joel Granados <j.granados@samsung.com>
Date: Wed, 21 Jun 2023 12:03:24 +0000
Subject: Re: [PATCH 06/11] sysctl: Add size to register_net_sysctl function
Message-Id: <20230621120324.cl2admxrku7ilecm@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="je5dyz423x2mm343"
List-Id: <dccp.vger.kernel.org>
References: <20230621091000.424843-7-j.granados@samsung.com>
In-Reply-To: <20230621091000.424843-7-j.granados@samsung.com>
To: dccp@vger.kernel.org

--je5dyz423x2mm343
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hey Dan

On Wed, Jun 21, 2023 at 01:23:52PM +0300, Dan Carpenter wrote:
> On Wed, Jun 21, 2023 at 12:47:30PM +0300, Dan Carpenter wrote:
> > The patchset doesn't include the actual interesting changes, just a
> > bunch of mechanical prep work.
> >=20
> > On Wed, Jun 21, 2023 at 11:09:55AM +0200, Joel Granados wrote:
> > > diff --git a/net/ieee802154/6lowpan/reassembly.c b/net/ieee802154/6lo=
wpan/reassembly.c
> > > index a91283d1e5bf..7b717434368c 100644
> > > --- a/net/ieee802154/6lowpan/reassembly.c
> > > +++ b/net/ieee802154/6lowpan/reassembly.c
> > > @@ -379,7 +379,8 @@ static int __net_init lowpan_frags_ns_sysctl_regi=
ster(struct net *net)
> > >  	table[1].extra2	=3D &ieee802154_lowpan->fqdir->high_thresh;
> > >  	table[2].data	=3D &ieee802154_lowpan->fqdir->timeout;
> > > =20
> > > -	hdr =3D register_net_sysctl(net, "net/ieee802154/6lowpan", table);
> > > +	hdr =3D register_net_sysctl(net, "net/ieee802154/6lowpan", table,
> > > +				  ARRAY_SIZE(lowpan_frags_ns_ctl_table));
> >=20
> > For example, in lowpan_frags_ns_sysctl_register() the sentinel is
> > sometimes element zero if the user doesn't have enough permissions.  I
> > would want to ensure that was handled correctly, but that's going to be
> > done later in a completely different patchset.  I'm definitely not going
> > to remember to check.
>=20
> On reflecting the patch is obviously wrong.  It should be pass zero as
> table_size in that case.  See diff at the end.
yes

>=20
> There is a similar bug in neigh_sysctl_register() where we use memset to
> zero out the whole table.  And another in __ip_vs_lblc_init().  I used
> the smatch cross function database
> 	`smdb.py where ctl_table procname | grep '(null)' | grep min-max`
> to make a list of functions which set procname to zero.
Awesome. That is homework on my part for V2. It gives me a way forward.
Thx!!!

>=20
> Probably we should add a WARN_ON() if procname is zero in the new code
> which doesn't use sentinels.
Yes

>=20
> regards,
> dan carpenter
>=20
> drivers/char/random.c          | proc_do_uuid                   | (struct=
 ctl_table)->procname | 0
> fs/proc/proc_sysctl.c          | new_dir                        | (struct=
 ctl_table)->procname | 48,3906148897379000352
> fs/proc/proc_sysctl.c          | new_links                      | (struct=
 ctl_table)->procname | 4096-ptr_max
> arch/arm64/kernel/fpsimd.c     | vec_proc_do_default_vl         | (struct=
 ctl_table)->procname | 0
> arch/arm64/kernel/armv8_deprecated.c | register_insn_emulation        | (=
struct ctl_table)->procname | 0-u64max
> kernel/sysctl-test.c           | sysctl_test_api_dointvec_null_tbl_data |=
 (struct ctl_table)->procname | 7612622206476333056
> kernel/sysctl-test.c           | sysctl_test_api_dointvec_table_maxlen_un=
set | (struct ctl_table)->procname | 7612622206476333056
> kernel/sysctl-test.c           | sysctl_test_api_dointvec_table_len_is_ze=
ro | (struct ctl_table)->procname | 7612622206476333056
> kernel/sysctl-test.c           | sysctl_test_api_dointvec_table_read_but_=
position_set | (struct ctl_table)->procname | 7612622206476333056
> kernel/sysctl-test.c           | sysctl_test_dointvec_read_happy_single_p=
ositive | (struct ctl_table)->procname | 7612622206476333056
> kernel/sysctl-test.c           | sysctl_test_dointvec_read_happy_single_n=
egative | (struct ctl_table)->procname | 7612622206476333056
> kernel/sysctl-test.c           | sysctl_test_dointvec_write_happy_single_=
positive | (struct ctl_table)->procname | 7612622206476333056
> kernel/sysctl-test.c           | sysctl_test_dointvec_write_happy_single_=
negative | (struct ctl_table)->procname | 7612622206476333056
> kernel/sysctl-test.c           | sysctl_test_api_dointvec_write_single_le=
ss_int_min | (struct ctl_table)->procname | 7612622206476333056
> kernel/sysctl-test.c           | sysctl_test_api_dointvec_write_single_gr=
eater_int_max | (struct ctl_table)->procname | 7612622206476333056
> kernel/sysctl.c                | proc_do_static_key             | (struct=
 ctl_table)->procname | 0
> kernel/kexec_core.c            | kexec_limit_handler            | (struct=
 ctl_table)->procname | 0
> kernel/bpf/syscall.c           | bpf_stats_handler              | (struct=
 ctl_table)->procname | 0
> net/core/sysctl_net_core.c     | rps_sock_flow_sysctl           | (struct=
 ctl_table)->procname | 0
> net/core/sysctl_net_core.c     | set_default_qdisc              | (struct=
 ctl_table)->procname | 0
> net/core/neighbour.c           | neigh_sysctl_register          | (struct=
 ctl_table)->procname | 0
> net/netfilter/ipvs/ip_vs_lblc.c | __ip_vs_lblc_init              | (struc=
t ctl_table)->procname | 0-u64max
> net/netfilter/ipvs/ip_vs_lblcr.c | __ip_vs_lblcr_init             | (stru=
ct ctl_table)->procname | 0-u64max
> net/netfilter/ipvs/ip_vs_ctl.c | proc_do_defense_mode           | (struct=
 ctl_table)->procname | 0
> net/netfilter/ipvs/ip_vs_ctl.c | proc_do_sync_threshold         | (struct=
 ctl_table)->procname | 0
> net/netfilter/ipvs/ip_vs_ctl.c | proc_do_sync_ports             | (struct=
 ctl_table)->procname | 0
> net/netfilter/ipvs/ip_vs_ctl.c | ipvs_proc_est_nice             | (struct=
 ctl_table)->procname | 0
> net/netfilter/ipvs/ip_vs_ctl.c | ipvs_proc_run_estimation       | (struct=
 ctl_table)->procname | 0
> net/netfilter/ipvs/ip_vs_ctl.c | ip_vs_control_net_init_sysctl  | (struct=
 ctl_table)->procname | 0-u64max
> net/netfilter/nf_log.c         | netfilter_log_sysctl_init      | (struct=
 ctl_table)->procname | 0-u64max
> net/sctp/sysctl.c              | proc_sctp_do_hmac_alg          | (struct=
 ctl_table)->procname | 0
> net/sctp/sysctl.c              | proc_sctp_do_rto_min           | (struct=
 ctl_table)->procname | 0
> net/sctp/sysctl.c              | proc_sctp_do_rto_max           | (struct=
 ctl_table)->procname | 0
> net/sctp/sysctl.c              | proc_sctp_do_auth              | (struct=
 ctl_table)->procname | 0
> net/sctp/sysctl.c              | proc_sctp_do_udp_port          | (struct=
 ctl_table)->procname | 0
> net/sctp/sysctl.c              | proc_sctp_do_probe_interval    | (struct=
 ctl_table)->procname | 0
> net/ipv6/route.c               | ipv6_route_sysctl_init         | (struct=
 ctl_table)->procname | 0-u64max
> net/ipv6/addrconf.c            | addrconf_sysctl_addr_gen_mode  | (struct=
 ctl_table)->procname | 0
> net/ieee802154/6lowpan/reassembly.c | lowpan_frags_ns_sysctl_register | (=
struct ctl_table)->procname | 0-u64max
> net/xfrm/xfrm_sysctl.c         | xfrm_sysctl_init               | (struct=
 ctl_table)->procname | 0-u64max
> net/phonet/sysctl.c            | proc_local_port_range          | (struct=
 ctl_table)->procname | 0
> net/ipv4/route.c               | sysctl_route_net_init          | (struct=
 ctl_table)->procname | 0-u64max
> net/ipv4/sysctl_net_ipv4.c     | ipv4_local_port_range          | (struct=
 ctl_table)->procname | 0
> net/ipv4/sysctl_net_ipv4.c     | ipv4_privileged_ports          | (struct=
 ctl_table)->procname | 0
> net/ipv4/sysctl_net_ipv4.c     | ipv4_ping_group_range          | (struct=
 ctl_table)->procname | 0
> net/ipv4/sysctl_net_ipv4.c     | proc_tcp_congestion_control    | (struct=
 ctl_table)->procname | 0
> net/ipv4/sysctl_net_ipv4.c     | proc_tcp_available_congestion_control | =
(struct ctl_table)->procname | 0
> net/ipv4/sysctl_net_ipv4.c     | proc_allowed_congestion_control | (struc=
t ctl_table)->procname | 0
> net/ipv4/sysctl_net_ipv4.c     | proc_tcp_fastopen_key          | (struct=
 ctl_table)->procname | 0
> net/ipv4/sysctl_net_ipv4.c     | proc_tcp_available_ulp         | (struct=
 ctl_table)->procname | 0
> net/ipv4/sysctl_net_ipv4.c     | proc_tcp_ehash_entries         | (struct=
 ctl_table)->procname | 0
> net/ipv4/sysctl_net_ipv4.c     | proc_udp_hash_entries          | (struct=
 ctl_table)->procname | 0
>=20
> diff --git a/net/ieee802154/6lowpan/reassembly.c b/net/ieee802154/6lowpan=
/reassembly.c
> index a91283d1e5bf..749238d38014 100644
> --- a/net/ieee802154/6lowpan/reassembly.c
> +++ b/net/ieee802154/6lowpan/reassembly.c
> @@ -360,6 +360,7 @@ static int __net_init lowpan_frags_ns_sysctl_register=
(struct net *net)
>  	struct ctl_table_header *hdr;
>  	struct netns_ieee802154_lowpan *ieee802154_lowpan =3D
>  		net_ieee802154_lowpan(net);
> +	size_t table_size =3D ARRAY_SIZE(lowpan_frags_ns_ctl_table);
> =20
>  	table =3D lowpan_frags_ns_ctl_table;
>  	if (!net_eq(net, &init_net)) {
> @@ -369,8 +370,10 @@ static int __net_init lowpan_frags_ns_sysctl_registe=
r(struct net *net)
>  			goto err_alloc;
> =20
>  		/* Don't export sysctls to unprivileged users */
> -		if (net->user_ns !=3D &init_user_ns)
> +		if (net->user_ns !=3D &init_user_ns) {
>  			table[0].procname =3D NULL;
> +			table_size =3D 0;
> +		}
>  	}
> =20
>  	table[0].data	=3D &ieee802154_lowpan->fqdir->high_thresh;
> @@ -379,7 +382,7 @@ static int __net_init lowpan_frags_ns_sysctl_register=
(struct net *net)
>  	table[1].extra2	=3D &ieee802154_lowpan->fqdir->high_thresh;
>  	table[2].data	=3D &ieee802154_lowpan->fqdir->timeout;
> =20
> -	hdr =3D register_net_sysctl(net, "net/ieee802154/6lowpan", table);
> +	hdr =3D register_net_sysctl(net, "net/ieee802154/6lowpan", table, table=
_size);
>  	if (hdr =3D=3D NULL)
>  		goto err_reg;
> =20

--=20

Joel Granados

--je5dyz423x2mm343
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQGzBAABCgAdFiEErkcJVyXmMSXOyyeQupfNUreWQU8FAmSS5wsACgkQupfNUreW
QU9ERQwAgEMy70wE4h18ynQTGRx76Q41zwefjWXFjEGR0K3NIsFmJQ0zHEbUM4QJ
IAZlo1uMboPLnI3bAsabEclKxOWcFy09FHUrVxLBEA2W6++zEHwohyoCKbOTxX47
T8PRYwwPkowWc4cF1iRrHsJlBU9xPYDzNpwFIM/hx/OFxPgcs4jpLZPN9i49q0Lx
ikkO54H2IHbPeRQb65JbXwFqG4KwDDJw3Y4pdmItfiqSuRqTmAS+9yLSOqnMn6Nc
f3C8/IzSg+3FYe4VBKnDur0si+IDxn+BOCHTJoPr+J/Lb9wk8/ZtS3dtxy+wf/41
CdEhbC17uw6GqbdzvAh6uENWMUfACrEPQnjZmu1IulsnpaP2U6fOJNRvVuibR9vh
KwdpxWSezi8xZ29gYfJbYjl5ckpT1H9zZhaSO23hgYzq7KVLr45hR/A+IQGamBYc
K/GWPGudYiQgXWTyk+CUA6rCvIVQDY0g92E5iONzE9JweFTG9pCFztodAJL16fPI
wgfgt0fB
=XFZg
-----END PGP SIGNATURE-----

--je5dyz423x2mm343--
