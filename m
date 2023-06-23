From: Joel Granados <j.granados@samsung.com>
Date: Fri, 23 Jun 2023 14:21:26 +0000
Subject: Re: [PATCH 06/11] sysctl: Add size to register_net_sysctl function
Message-Id: <20230623142126.rgdabyokvuwshhmj@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="swgbxx6ykpv57frf"
List-Id: <dccp.vger.kernel.org>
References: <20230621091000.424843-7-j.granados@samsung.com>
In-Reply-To: <20230621091000.424843-7-j.granados@samsung.com>
To: dccp@vger.kernel.org

--swgbxx6ykpv57frf
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Just answering to dan and the lists to avoid noise

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
>=20
> There is a similar bug in neigh_sysctl_register() where we use memset to
> zero out the whole table.  And another in __ip_vs_lblc_init().  I used
> the smatch cross function database
> 	`smdb.py where ctl_table procname | grep '(null)' | grep min-max`
> to make a list of functions which set procname to zero.
>=20
> Probably we should add a WARN_ON() if procname is zero in the new code
> which doesn't use sentinels.
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
> net/netfilter/nf_log.c         | netfilter_log_sysctl_init      | (struct=
 ctl_table)->procname | 0-u64max
^^^ : These are all false positives as non-sentinel procname gets
set to a string on the register sysctl path.

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
> net/ipv6/addrconf.c            | addrconf_sysctl_addr_gen_mode  | (struct=
 ctl_table)->procname | 0
> net/phonet/sysctl.c            | proc_local_port_range          | (struct=
 ctl_table)->procname | 0
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
^^^ : procname gets set to NULL but is not used to register. just as a
temp ctl_table. Can be ignored.

> net/core/neighbour.c           | neigh_sysctl_register          | (struct=
 ctl_table)->procname | 0
^^^ : This is one is tricky. I had handled the case where the sentinel
is cleared by setting procname to NULL.

> net/netfilter/ipvs/ip_vs_lblc.c | __ip_vs_lblc_init              | (struc=
t ctl_table)->procname | 0-u64max
> net/netfilter/ipvs/ip_vs_lblcr.c | __ip_vs_lblcr_init             | (stru=
ct ctl_table)->procname | 0-u64max
^^^ : These two where caught by your check. THX!!!!!!

> net/netfilter/ipvs/ip_vs_ctl.c | ip_vs_control_net_init_sysctl  | (struct=
 ctl_table)->procname | 0-u64max
^^^ : This one is another one that was caught.
For this file I noticed that we setup the entire ctl_table for both privile=
ged
and unprivileged users. It seems that we could just skip all the setup
needed for the unprivileged user. Please tell me and I can maybe come
with a patch for that.

> net/ipv6/route.c               | ipv6_route_sysctl_init         | (struct=
 ctl_table)->procname | 0-u64max
> net/ieee802154/6lowpan/reassembly.c | lowpan_frags_ns_sysctl_register | (=
struct ctl_table)->procname | 0-u64max
> net/xfrm/xfrm_sysctl.c         | xfrm_sysctl_init               | (struct=
 ctl_table)->procname | 0-u64max
> net/ipv4/route.c               | sysctl_route_net_init          | (struct=
 ctl_table)->procname | 0-u64max
^^^ : caught by your check!

In total you caught 8 valid errors.

Thx again.

Best

--=20

Joel Granados

--swgbxx6ykpv57frf
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQGzBAABCgAdFiEErkcJVyXmMSXOyyeQupfNUreWQU8FAmSVqmMACgkQupfNUreW
QU9g2wv/TmhtYGAUfhchEJ5DYrqk7RdbDAd+0qI8p6L0euVZ8FFDfVZODTOUVA9/
mvmcT0HvLEy23U3mrCbC2e49Yn7EiKs87UMXHsQRXMwMSfRN8+i5Mnaz7Fd1AZmh
e1EuAk+Y0K2AW8KaO/Av4yVqWc289VgEyPJABABeEh44pitZ9THyHjuuR8+/4yKN
NvPpl5x3pbrQ1OMGD9yUiDtJZ1rYZ0Qpus7pXZcbFMOoZa1VNRzhorx1PuqlN5fA
eusGeiqE32G6z4B1bEOMzJ0Vw4a5fyzOToVPCACfak78WfrnF4LNeClh02gEZVJh
3Vc0OVySb4DD3v51KWvUFowmbL1OB7pnsIk147h9PqwRpmlCWGmx44QUejXBAkF/
O6wMW1SxWEGFVCFc2OX/cTf2JLLEdqACpDw7vzi8OUMZ4TSv4MMXpmEztGByCjZy
6e8Bh3SNVZVC7lUkxZFp1oWl2J2dfXh/J0LwJMz2m0Ev1sEFAgKVosISHUzq3+Aw
YPXJThO2
=HDho
-----END PGP SIGNATURE-----

--swgbxx6ykpv57frf--
