From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Tue, 28 Feb 2006 23:38:51 +0000
Subject: Re: [BUG] DCCP : Suspected race in ackvec code
Message-Id: <39e6f6c70602281538g359e6851k6e06c9589f401b33@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cbec11ac0602281518uc14fe5fl73eda47b211a7d9f@mail.gmail.com>
In-Reply-To: <cbec11ac0602281518uc14fe5fl73eda47b211a7d9f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2/28/06, Ian McDonald <imcdnzl@gmail.com> wrote:
> When send_ackvec sysctl is on DCCP locks the machine. Unfortunately it
> doesn't send any output to the kernel.

I'm getting below results by just stopping the syslog daemon and setting
printk log level to 9:

[root@qemu ~]# service syslog stop
[root@qemu ~]# echo 9 > /proc/sys/kernel/printk

With this the printk messages goes to the console, allowing us to see the
dccp_pr_debug messages till the very moment when a soft lockup happens
at dccp_ackvec_parse.

[root@qemu ~]# modprobe dccp dccp_debug=1
[root@qemu ~]# echo 3 > /proc/sys/net/dccp/default/rx_ccid
[root@qemu ~]# echo 3 > /proc/sys/net/dccp/default/tx_ccid

Oh well, not reproducing it right now, try with these settings to see you
reproduce it in your setup.

Regards,

- Arnaldo
