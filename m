From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 21 Feb 2007 20:58:16 +0000
Subject: Re: [dccp] DCCP and iotcl
Message-Id: <5640c7e00702211258k2f538efbqb590dae857cd6083@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2/22/07, patrick andrieux <patrick.andrieux@gmail.com> wrote:
> Hi,
>
> I'm doing some research on DCCP, and I'm trying to use ioctl() function.
> I ran the sample code (from
> http://linux-net.osdl.org/index.php/DCCP_Testing ) using
> -proto TCP. I added a few lines to use ioctl(), and it works with TCP
> (return value is 0).

Which sample code are you using? What version of Linux? Any extra patches?
>
> But it doesn't work with DCCP, I get -1 as return value.
> I took a look at DCCP source code, and basically my first step would be to
> display in the kernel log what dccp_ioctl() prints. My guess is that
> functionalities to use ioctl() are not implemented yet. am I right ?
> Is there any way to get some information from DCCP other than sysctl ?
>
Yes - use dccp_probe. It's in the source code tree and also on the
Wiki you were looking at.

cc'd dccp@vger.kernel.org as this is where we can discuss more (as per Leandro)

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
