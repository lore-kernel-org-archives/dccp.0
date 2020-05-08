From: Andrii Nakryiko <andrii.nakryiko@gmail.com>
Date: Fri, 08 May 2020 17:59:59 +0000
Subject: Re: [PATCH bpf-next 14/17] libbpf: Add support for SK_LOOKUP program type
Message-Id: <CAEf4BzYbZpsd69TkSgYeP+D8sGKogK2YGhwTxiNWr3RpHVD_=w@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20200506125514.1020829-15-jakub@cloudflare.com>
In-Reply-To: <20200506125514.1020829-15-jakub@cloudflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, May 8, 2020 at 10:52 AM Yonghong Song <yhs@fb.com> wrote:
>
>
>
> On 5/8/20 10:41 AM, Andrii Nakryiko wrote:
> > On Wed, May 6, 2020 at 5:58 AM Jakub Sitnicki <jakub@cloudflare.com> wrote:
> >>
> >> Make libbpf aware of the newly added program type, and assign it a
> >> section name.
> >>
> >> Signed-off-by: Jakub Sitnicki <jakub@cloudflare.com>
> >> ---
> >>   tools/lib/bpf/libbpf.c        | 3 +++
> >>   tools/lib/bpf/libbpf.h        | 2 ++
> >>   tools/lib/bpf/libbpf.map      | 2 ++
> >>   tools/lib/bpf/libbpf_probes.c | 1 +
> >>   4 files changed, 8 insertions(+)
> >>
> >> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
> >> index 977add1b73e2..74f4a15dc19e 100644
> >> --- a/tools/lib/bpf/libbpf.c
> >> +++ b/tools/lib/bpf/libbpf.c
> >> @@ -6524,6 +6524,7 @@ BPF_PROG_TYPE_FNS(perf_event, BPF_PROG_TYPE_PERF_EVENT);
> >>   BPF_PROG_TYPE_FNS(tracing, BPF_PROG_TYPE_TRACING);
> >>   BPF_PROG_TYPE_FNS(struct_ops, BPF_PROG_TYPE_STRUCT_OPS);
> >>   BPF_PROG_TYPE_FNS(extension, BPF_PROG_TYPE_EXT);
> >> +BPF_PROG_TYPE_FNS(sk_lookup, BPF_PROG_TYPE_SK_LOOKUP);
> >>
> >>   enum bpf_attach_type
> >>   bpf_program__get_expected_attach_type(struct bpf_program *prog)
> >> @@ -6684,6 +6685,8 @@ static const struct bpf_sec_def section_defs[] = {
> >>          BPF_EAPROG_SEC("cgroup/setsockopt",     BPF_PROG_TYPE_CGROUP_SOCKOPT,
> >>                                                  BPF_CGROUP_SETSOCKOPT),
> >>          BPF_PROG_SEC("struct_ops",              BPF_PROG_TYPE_STRUCT_OPS),
> >> +       BPF_EAPROG_SEC("sk_lookup",             BPF_PROG_TYPE_SK_LOOKUP,
> >> +                                               BPF_SK_LOOKUP),
> >>   };
> >>
> >>   #undef BPF_PROG_SEC_IMPL
> >> diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
> >> index f1dacecb1619..8373fbacbba3 100644
> >> --- a/tools/lib/bpf/libbpf.h
> >> +++ b/tools/lib/bpf/libbpf.h
> >> @@ -337,6 +337,7 @@ LIBBPF_API int bpf_program__set_perf_event(struct bpf_program *prog);
> >>   LIBBPF_API int bpf_program__set_tracing(struct bpf_program *prog);
> >>   LIBBPF_API int bpf_program__set_struct_ops(struct bpf_program *prog);
> >>   LIBBPF_API int bpf_program__set_extension(struct bpf_program *prog);
> >> +LIBBPF_API int bpf_program__set_sk_lookup(struct bpf_program *prog);
> >>
> >>   LIBBPF_API enum bpf_prog_type bpf_program__get_type(struct bpf_program *prog);
> >>   LIBBPF_API void bpf_program__set_type(struct bpf_program *prog,
> >> @@ -364,6 +365,7 @@ LIBBPF_API bool bpf_program__is_perf_event(const struct bpf_program *prog);
> >>   LIBBPF_API bool bpf_program__is_tracing(const struct bpf_program *prog);
> >>   LIBBPF_API bool bpf_program__is_struct_ops(const struct bpf_program *prog);
> >>   LIBBPF_API bool bpf_program__is_extension(const struct bpf_program *prog);
> >> +LIBBPF_API bool bpf_program__is_sk_lookup(const struct bpf_program *prog);
> >
> > cc Yonghong, bpf_iter programs should probably have similar
> > is_xxx/set_xxx functions?..
>
> Not sure about this. bpf_iter programs have prog type TRACING
> which is covered by the above bpf_program__is_tracing.

Ah, right, never mind then, sorry.

>
> >
> >>
> >>   /*
> >>    * No need for __attribute__((packed)), all members of 'bpf_map_def'
> >> diff --git a/tools/lib/bpf/libbpf.map b/tools/lib/bpf/libbpf.map
> >> index e03bd4db827e..113ac0a669c2 100644
> >> --- a/tools/lib/bpf/libbpf.map
> >> +++ b/tools/lib/bpf/libbpf.map
> >> @@ -253,6 +253,8 @@ LIBBPF_0.0.8 {
> >>                  bpf_program__set_attach_target;
> >>                  bpf_program__set_lsm;
> >>                  bpf_set_link_xdp_fd_opts;
> >> +               bpf_program__is_sk_lookup;
> >> +               bpf_program__set_sk_lookup;
> >>   } LIBBPF_0.0.7;
> >>
> >
> > 0.0.8 is sealed, please add them into 0.0.9 map below
> >
> >>   LIBBPF_0.0.9 {
> >> diff --git a/tools/lib/bpf/libbpf_probes.c b/tools/lib/bpf/libbpf_probes.c
> >> index 2c92059c0c90..5c6d3e49f254 100644
> >> --- a/tools/lib/bpf/libbpf_probes.c
> >> +++ b/tools/lib/bpf/libbpf_probes.c
> >> @@ -109,6 +109,7 @@ probe_load(enum bpf_prog_type prog_type, const struct bpf_insn *insns,
> >>          case BPF_PROG_TYPE_STRUCT_OPS:
> >>          case BPF_PROG_TYPE_EXT:
> >>          case BPF_PROG_TYPE_LSM:
> >> +       case BPF_PROG_TYPE_SK_LOOKUP:
> >>          default:
> >>                  break;
> >>          }
> >> --
> >> 2.25.3
> >>
