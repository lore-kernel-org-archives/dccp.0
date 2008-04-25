From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Fri, 25 Apr 2008 08:42:53 +0000
Subject: Re: DCCP iperf
Message-Id: <200804251042.54071.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <324670298.69157.1209100427851.JavaMail.nobody@mail51.abv.bg>
In-Reply-To: <324670298.69157.1209100427851.JavaMail.nobody@mail51.abv.bg>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Friday 25 of April 2008, napisa=B3e=B6:
> Dear All,
>
>  My name is Rostislava Slavova. I am a master student in Technical
> University of Sofia and I'm working on my thesis about the new transport
> protocols and that is why I'm much interested in DCCP. But I faced some
I'm in a very similar situation. :-)

> difficultness running it. I would like to ask you for some help to start
> using the DCCP test source tree. I compiled the kernel to enable DCCP, but
> still when trying to run iperf with DCCP have the message "Protocol not
> available". How to compile the code from the DCCP test tree so to make the
> DCCP run, using iperf for the beginning?
>
Never tried to use iperf with DCCP (it may be that released versions do not=
=20
support DCCP) but DCCP alone certainly works for me. If you want to use tes=
t=20
tree first pull it from git://eden-feed.erg.abdn.ac.uk/dccp_exp.git then=20
switch to correct branch (most probably origin/dccp), and compile with DCCP=
=20
enabled:
$ cat .config| grep -i dccp
CONFIG_NETFILTER_XT_MATCH_DCCP=3Dm
CONFIG_IP_DCCP=3Dm
CONFIG_INET_DCCP_DIAG=3Dm
CONFIG_IP_DCCP_ACKVEC=3Dy
# DCCP CCIDs Configuration (EXPERIMENTAL)
CONFIG_IP_DCCP_CCID2=3Dm
CONFIG_IP_DCCP_CCID2_DEBUG=3Dy
CONFIG_IP_DCCP_CCID3=3Dm
CONFIG_IP_DCCP_CCID3_DEBUG=3Dy
CONFIG_IP_DCCP_CCID3_RTO=1000
CONFIG_IP_DCCP_TFRC_LIB=3Dm
CONFIG_IP_DCCP_TFRC_DEBUG=3Dy
# DCCP Kernel Hacking
CONFIG_IP_DCCP_DEBUG=3Dy
CONFIG_NET_DCCPPROBE=3Dm

Also have a look at http://wand.cs.waikato.ac.nz/~iam4/dccp/index.html, in =

particular http://wand.cs.waikato.ac.nz/~iam4/software/index.html
--=20
Regards,
Tomasz Grobelny
