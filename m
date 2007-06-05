From: "Patrick Andrieux" <patrick.andrieux@gmail.com>
Date: Tue, 05 Jun 2007 14:09:16 +0000
Subject: Re: segfault : modprobe dccp_probe
Message-Id: <fca78b970706050709w87d58e2laf37561de9dc930a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <fca78b970706050607p557cc70u981116223fc72376@mail.gmail.com>
In-Reply-To: <fca78b970706050607p557cc70u981116223fc72376@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 05/06/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> On 6/5/07, Patrick Andrieux <patrick.andrieux@gmail.com> wrote:
> > Hi,
> >
> > I have a segfault when inserting dccp_probe module on Dave Miller's
> > tree *without* Ian's patches. I got it using this cmd line :
>
> Question, does it also segfaults _with_ Ian's patches?

I don't know because I didn't try with Ian's patches on this kernel.
But I tried on 2.6.20.12 kernel with Ian's patches, and dccp_probe works.


>
> > do_page_fault+0x436/0x509
> > Jun  5 12:26:55 dccpServer kernel: [ 1027.751869]  [<c031fd4a>]
> > error_code+0x6a/0x70
> > Jun  5 12:26:55 dccpServer kernel: [ 1027.751873]  [<c0321921>]
> > __register_kprobe+0x23a/0x294
> > Jun  5 12:26:55 dccpServer kernel: [ 1027.751876]  [<c0321994>]
> > register_jprobe+0x19/0x1b
>
> I ask this because it is segfaulting at dccpprobe_init time, when it
> is registering the jprobe. To me it looks like something changed in
> the jprobes infrastructure and we are seeing a fallout from that. But
> I haven't investigated this more than looking at this backtrace.
>

I'll try to patch davem's tree and I'll get back to you.



> > Jun  5 12:26:55 dccpServer kernel: [  1027.751880]  [<f8a27076>]
> > dccpprobe_init+0x76/0xb4 [dccp_probe]
> > Jun  5 12:26:55 dccpServer kernel: [ 1027.751885]  [<c0137d1f>]
> > sys_init_module+0x12d5/0x1415
> > Jun  5 12:26:55 dccpServer kernel: [ 1027.751890 ]  [<c0103db2>]
> > sysenter_past_esp+0x5f/0x99
> > Jun  5 12:26:55 dccpServer kernel: [ 1027.751893]  ===========> >
> > Let me know if you need anything else.
> >
> > rgds,
> > Patrick.
