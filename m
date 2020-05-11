From: Martin KaFai Lau <kafai@fb.com>
Date: Mon, 11 May 2020 19:45:20 +0000
Subject: Re: [PATCH bpf-next v2 00/17] Run a BPF program on socket lookup
Message-Id: <20200511194520.pr5d74ao34jigvof@kafai-mbp.dhcp.thefacebook.com>
List-Id: <dccp.vger.kernel.org>
References: <20200511185218.1422406-1-jakub@cloudflare.com>
In-Reply-To: <20200511185218.1422406-1-jakub@cloudflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

On Mon, May 11, 2020 at 08:52:01PM +0200, Jakub Sitnicki wrote:

[ ... ]

> Performance considerations
> =============
> 
> Patch set adds new code on receive hot path. This comes with a cost,
> especially in a scenario of a SYN flood or small UDP packet flood.
> 
> Measuring the performance penalty turned out to be harder than expected
> because socket lookup is fast. For CPUs to spend >= 1% of time in socket
> lookup we had to modify our setup by unloading iptables and reducing the
> number of routes.
> 
> The receiver machine is a Cloudflare Gen 9 server covered in detail at [0].
> In short:
> 
>  - 24 core Intel custom off-roadmap 1.9Ghz 150W (Skylake) CPU
>  - dual-port 25G Mellanox ConnectX-4 NIC
>  - 256G DDR4 2666Mhz RAM
> 
> Flood traffic pattern:
> 
>  - source: 1 IP, 10k ports
>  - destination: 1 IP, 1 port
>  - TCP - SYN packet
>  - UDP - Len=0 packet
> 
> Receiver setup:
> 
>  - ingress traffic spread over 4 RX queues,
>  - RX/TX pause and autoneg disabled,
>  - Intel Turbo Boost disabled,
>  - TCP SYN cookies always on.
> 
> For TCP test there is a receiver process with single listening socket
> open. Receiver is not accept()'ing connections.
> 
> For UDP the receiver process has a single UDP socket with a filter
> installed, dropping the packets.
> 
> With such setup in place, we record RX pps and cpu-cycles events under
> flood for 60 seconds in 3 configurations:
> 
>  1. 5.6.3 kernel w/o this patch series (baseline),
>  2. 5.6.3 kernel with patches applied, but no SK_LOOKUP program attached,
>  3. 5.6.3 kernel with patches applied, and SK_LOOKUP program attached;
>     BPF program [1] is doing a lookup LPM_TRIE map with 200 entries.
Is the link in [1] up-to-date?  I don't see it calling bpf_sk_assign().

> 
> RX pps measured with `ifpps -d <dev> -t 1000 --csv --loop` for 60 seconds.
> 
> | tcp4 SYN flood               | rx pps (mean ± sstdev) | Δ rx pps |
> |------------------------------+------------------------+----------|
> | 5.6.3 vanilla (baseline)     | 939,616 ± 0.5%         |        - |
> | no SK_LOOKUP prog attached   | 929,275 ± 1.2%         |    -1.1% |
> | with SK_LOOKUP prog attached | 918,582 ± 0.4%         |    -2.2% |
> 
> | tcp6 SYN flood               | rx pps (mean ± sstdev) | Δ rx pps |
> |------------------------------+------------------------+----------|
> | 5.6.3 vanilla (baseline)     | 875,838 ± 0.5%         |        - |
> | no SK_LOOKUP prog attached   | 872,005 ± 0.3%         |    -0.4% |
> | with SK_LOOKUP prog attached | 856,250 ± 0.5%         |    -2.2% |
> 
> | udp4 0-len flood             | rx pps (mean ± sstdev) | Δ rx pps |
> |------------------------------+------------------------+----------|
> | 5.6.3 vanilla (baseline)     | 2,738,662 ± 1.5%       |        - |
> | no SK_LOOKUP prog attached   | 2,576,893 ± 1.0%       |    -5.9% |
> | with SK_LOOKUP prog attached | 2,530,698 ± 1.0%       |    -7.6% |
> 
> | udp6 0-len flood             | rx pps (mean ± sstdev) | Δ rx pps |
> |------------------------------+------------------------+----------|
> | 5.6.3 vanilla (baseline)     | 2,867,885 ± 1.4%       |        - |
> | no SK_LOOKUP prog attached   | 2,646,875 ± 1.0%       |    -7.7% |
What is causing this regression?

> | with SK_LOOKUP prog attached | 2,520,474 ± 0.7%       |   -12.1% |
This also looks very different from udp4.

> 
> Also visualized on bpf-sk-lookup-v1-rx-pps.png chart [2].
> 
> cpu-cycles measured with `perf record -F 999 --cpu 1-4 -g -- sleep 60`.
> 
> |                              |      cpu-cycles events |          |
> | tcp4 SYN flood               | __inet_lookup_listener | Δ events |
> |------------------------------+------------------------+----------|
> | 5.6.3 vanilla (baseline)     |                  1.12% |        - |
> | no SK_LOOKUP prog attached   |                  1.31% |    0.19% |
> | with SK_LOOKUP prog attached |                  3.05% |    1.93% |
> 
> |                              |      cpu-cycles events |          |
> | tcp6 SYN flood               |  inet6_lookup_listener | Δ events |
> |------------------------------+------------------------+----------|
> | 5.6.3 vanilla (baseline)     |                  1.05% |        - |
> | no SK_LOOKUP prog attached   |                  1.68% |    0.63% |
> | with SK_LOOKUP prog attached |                  3.15% |    2.10% |
> 
> |                              |      cpu-cycles events |          |
> | udp4 0-len flood             |      __udp4_lib_lookup | Δ events |
> |------------------------------+------------------------+----------|
> | 5.6.3 vanilla (baseline)     |                  3.81% |        - |
> | no SK_LOOKUP prog attached   |                  5.22% |    1.41% |
> | with SK_LOOKUP prog attached |                  8.20% |    4.39% |
> 
> |                              |      cpu-cycles events |          |
> | udp6 0-len flood             |      __udp6_lib_lookup | Δ events |
> |------------------------------+------------------------+----------|
> | 5.6.3 vanilla (baseline)     |                  5.51% |        - |
> | no SK_LOOKUP prog attached   |                  6.51% |    1.00% |
> | with SK_LOOKUP prog attached |                 10.14% |    4.63% |
> 
> Also visualized on bpf-sk-lookup-v1-cpu-cycles.png chart [3].
> 

[ ... ]

> 
> [0] https://urldefense.proofpoint.com/v2/url?u=https-3A__blog.cloudflare.com_a-2Dtour-2Dinside-2Dcloudflares-2Dg9-2Dservers_&d=DwIDaQ&c=5VD0RTtNlTh3ycd41b3MUw&r=VQnoQ7LvghIj0gVEaiQSUw&m=v4r30a5NaPFxNXVRakV9SeJkshbI4G4c5D83yZtGm-g&s=PhkIqKdmL12ZMD_6jY_rALjmO2ahv_KNF3F7TikyfTo&e= 
> [1] https://github.com/majek/inet-tool/blob/master/ebpf/inet-kern.c
> [2] https://urldefense.proofpoint.com/v2/url?u=https-3A__drive.google.com_file_d_1HrrjWhQoVlqiqT73-5FeLtWMPhuGPKhGFX_&d=DwIDaQ&c=5VD0RTtNlTh3ycd41b3MUw&r=VQnoQ7LvghIj0gVEaiQSUw&m=v4r30a5NaPFxNXVRakV9SeJkshbI4G4c5D83yZtGm-g&s=9tums5TZ16ttY69vEHkzyiEkblxT3iwvm0mFjZySJXo&e= 
> [3] https://urldefense.proofpoint.com/v2/url?u=https-3A__drive.google.com_file_d_1cYPPOlGg7M-2DbkzI4RW1SOm49goI4LYbb_&d=DwIDaQ&c=5VD0RTtNlTh3ycd41b3MUw&r=VQnoQ7LvghIj0gVEaiQSUw&m=v4r30a5NaPFxNXVRakV9SeJkshbI4G4c5D83yZtGm-g&s=VWolTQx3GVmSh2J7TQixTlGvRTb6S9qDNx4N8id5lf8&e= 
> [RFCv1] https://lore.kernel.org/bpf/20190618130050.8344-1-jakub@cloudflare.com/
> [RFCv2] https://lore.kernel.org/bpf/20190828072250.29828-1-jakub@cloudflare.com/
