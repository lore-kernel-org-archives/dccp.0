From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Sun, 12 Nov 2006 00:36:48 +0000
Subject: Re: [PATCH RFC] SELinux support for DCCP
Message-Id: <39e6f6c70611111636p2d919bafj9189ba9473f7c95a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
In-Reply-To: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/11/06, James Morris <jmorris@namei.org> wrote:
> Btw, I couldn't find anything to test DCCPv6 with (GNU netcat somehow
> lacks IPv6 support), so wrote some simple apps to do this:
>
> http://namei.org/misc/dccp/

Thanks for the new test apps, you can find some more here:

http://linux-net.osdl.org/index.php/DCCP

And in:

http://linux-net.osdl.org/index.php/DCCP#TODO_.26_testing

You can find a pointer to a ttcp mucho patched to support  IPv6 with
DCCP, TCP & UDP.
Ian has it here:

http://wand.net.nz/~iam4/dccp/ttcp_acme.c

Or you can get the latest one I store here:

http://vger.kernel.org/~acme/dccp/ttcp.c

- Arnaldo
