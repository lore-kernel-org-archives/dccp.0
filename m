From: Jakub Sitnicki <jakub@cloudflare.com>
Date: Mon, 11 May 2020 08:12:00 +0000
Subject: Re: [PATCH bpf-next 14/17] libbpf: Add support for SK_LOOKUP program type
Message-Id: <878shyvqjz.fsf@cloudflare.com>
List-Id: <dccp.vger.kernel.org>
References: <20200506125514.1020829-15-jakub@cloudflare.com>
In-Reply-To: <20200506125514.1020829-15-jakub@cloudflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, May 08, 2020 at 07:41 PM CEST, Andrii Nakryiko wrote:
> On Wed, May 6, 2020 at 5:58 AM Jakub Sitnicki <jakub@cloudflare.com> wrote:

[...]

>> diff --git a/tools/lib/bpf/libbpf.map b/tools/lib/bpf/libbpf.map
>> index e03bd4db827e..113ac0a669c2 100644
>> --- a/tools/lib/bpf/libbpf.map
>> +++ b/tools/lib/bpf/libbpf.map
>> @@ -253,6 +253,8 @@ LIBBPF_0.0.8 {
>>                 bpf_program__set_attach_target;
>>                 bpf_program__set_lsm;
>>                 bpf_set_link_xdp_fd_opts;
>> +               bpf_program__is_sk_lookup;
>> +               bpf_program__set_sk_lookup;
>>  } LIBBPF_0.0.7;
>>
>
> 0.0.8 is sealed, please add them into 0.0.9 map below
>

Ah, thanks. I missed that been rebases. Will fix in v2.
