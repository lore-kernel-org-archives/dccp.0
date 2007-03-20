From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 20 Mar 2007 21:45:56 +0000
Subject: Re: debugging messages
Message-Id: <5640c7e00703201445k4420e07eg1a73772b7733e91c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <fca78b970703200401s6ccb3ed4q73c002e495d10659@mail.gmail.com>
In-Reply-To: <fca78b970703200401s6ccb3ed4q73c002e495d10659@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/20/07, patrick andrieux <patrick.andrieux@gmail.com> wrote:
> Hi list !
>
> I'm trying to find out where debug messages are print out, like
> ccid3_pr_debug(...), DCCP_WARN(...), ....
> I compiled the latest kernel 2.6.20-3, with all DCCP options enabled
> (DCCP debug messages, ccid2/3 debugging messages, ....) and with all
> DCCP patches applied. But I still don't find any messages in log from
> /var/log/ .
> Did I missed something ?
> How can I get these messages ?
>
> Thanks.
>
> regards,
> Patrick.
> -

Hi there Patrick,

First of all you need to turn on debugging when you load the module
e.g. put something like this in /etc/modprobe.d/network
options dccp_ccid3 ccid3_debug=1
options dccp dccp_debug=1

and then make sure you're catching debug message in your
/etc/syslog.conf file with a line something like:
*.*         -/var/log/syslog

NB These file locations are for Debian. Look for the equivalent in your distro.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
