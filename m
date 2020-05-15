From: Jakub Sitnicki <jakub@cloudflare.com>
Date: Fri, 15 May 2020 12:28:30 +0000
Subject: Re: [PATCH bpf-next v2 05/17] inet: Run SK_LOOKUP BPF program on socket lookup
Message-Id: <87wo5d2xht.fsf@cloudflare.com>
List-Id: <dccp.vger.kernel.org>
References: <20200511185218.1422406-6-jakub@cloudflare.com>
In-Reply-To: <20200511185218.1422406-6-jakub@cloudflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, May 11, 2020 at 10:44 PM CEST, Alexei Starovoitov wrote:
> On Mon, May 11, 2020 at 08:52:06PM +0200, Jakub Sitnicki wrote:
>> Run a BPF program before looking up a listening socket on the receive path.
>> Program selects a listening socket to yield as result of socket lookup by
>> calling bpf_sk_assign() helper and returning BPF_REDIRECT code.
>>
>> Alternatively, program can also fail the lookup by returning with BPF_DROP,
>> or let the lookup continue as usual with BPF_OK on return.
>>
>> This lets the user match packets with listening sockets freely at the last
>> possible point on the receive path, where we know that packets are destined
>> for local delivery after undergoing policing, filtering, and routing.
>>
>> With BPF code selecting the socket, directing packets destined to an IP
>> range or to a port range to a single socket becomes possible.
>>
>> Suggested-by: Marek Majkowski <marek@cloudflare.com>
>> Reviewed-by: Lorenz Bauer <lmb@cloudflare.com>
>> Signed-off-by: Jakub Sitnicki <jakub@cloudflare.com>
>> ---

[...]

> Also please switch to bpf_link way of attaching. All system wide attachments
> should be visible and easily debuggable via 'bpftool link show'.
> Currently we're converting tc and xdp hooks to bpf_link. This new hook
> should have it from the beginning.

Just to clarify, I understood that bpf(BPF_PROG_ATTACH/DETACH) doesn't
have to be supported for new hooks.

Please correct me if I misunderstood.
