From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 21 Aug 2009 12:30:48 +0000
Subject: Re: DCCP module insertion issues
Message-Id: <20090821123047.GB6709@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <DD7F6BACE0940D4AA451F8762B4D513C025A6E8A@thot.clb.tcfr.thales>
In-Reply-To: <DD7F6BACE0940D4AA451F8762B4D513C025A6E8A@thot.clb.tcfr.thales>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Fri, Aug 21, 2009 at 10:22:45AM +0200, Julien.HUEBER@fr.thalesgroup.com escreveu:
> Hello, 
> I am currently working on DCCP in a research purpose but I am experiencing
> new issues that I don't understand.
>  
> We already have a Test-Bed with a couple of machines working with the latest
> version of the Linux Kernel (2.6.31-rc1) modified for DCCP, but when we
> tried to install this kernel on another computer the DCCP module isn't
> loading.
>  
> When we try to insert it manually we get the following error :
> # sudo insmod dccp.ko
> > insmod: error inserting 'dccp.ko' : -1 Socket type not supported

Lets try to see where in the insmod initiated sequence we can get such
an error:

We start by looking at the net/dccp/Makefile to see what are the object
files that are combined to generate dccp.ko:

obj-$(CONFIG_IP_DCCP) += dccp.o dccp_ipv4.o

dccp-y := ccid.o feat.o input.o minisocks.o options.o output.o proto.o timer.o

#
# CCID algorithms to be used by dccp.ko
#
# CCID-2 is default (RFC 4340, p. 77) and has Ack Vectors as dependency
dccp-y += ccids/ccid2.o ackvec.o

Ok, so if we set CONFIG_IP_DCCP to M, as is in most linux distros:

[acme@doppio linux-2.6-tip]$ grep ^CONFIG_IP_DCCP= /boot/config-2.6.29.6-217.2.7.fc11.x86_64 
CONFIG_IP_DCCP=m
[acme@doppio linux-2.6-tip]$ rpm -qf /boot/config-2.6.29.6-217.2.7.fc11.x86_64
kernel-2.6.29.6-217.2.7.fc11.x86_64
[acme@doppio linux-2.6-tip]$

We see we have to look at:

net/dccp/{dccp_ipv4,ccid,feat,input,minisocks,options,output,proto,timer,ackvec,ccids/ccid2}.c

for a module_init marked routine:

grep module_init net/dccp/{ipv4,ccid,feat,input,minisocks,options,output,proto,timer,ackvec,ccids/ccid2}.c

[acme@doppio linux-2.6-tip]$ grep module_init net/dccp/{ipv4,ccid,feat,input,minisocks,options,output,proto,timer,ackvec,ccids/ccid2}.c
net/dccp/ipv4.c:module_init(dccp_v4_init);
net/dccp/proto.c:module_init(dccp_init);
[acme@doppio linux-2.6-tip]$

The first one is a leftover from when dccp_ipv4.ko existed, now it is always
linked with dccp.ko, put that aside and lets look at dccp_init:

There is no return -ESOCKTNOSUPPORT...

The only place where I can think this could happen is if you tried to create an
AF_INET, SOCK_DCCP, then inet_create would try to autoload this module and then
for some reason the module wouldn't be found or SELinux wouldn't allow the user
to load it (recent development).

Is this with the test tree from Gerrit or using just what is in Linus's tree?

> We saw on the mailing list that this error can be caused by the timer
> resolution (on the post "dccp ccid3 : Runtime verification of timer
> resolution"). Our clocksource was "tsc", but even when changing it to
> "acpi_pm" (which is working just fine with DCCP on another machine) we are
> still getting this error.
> Moreover, DCCP used to work on this machine when an older version
> (2.6.26-rc8) of the modified Kernel was installed.
>  
> So I am running out of idea about this problem, if anyone could explain me
> what is the matter, or how can I get rid of it, it would be very helpful.
> Thanks,
> --
> Julien Hueber
>  
> MSc student in internship at Thales Communications
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
