From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 25 Oct 2007 17:14:01 +0000
Subject: Re: Gstreamer e DCCP: issues related to ccid-3
Message-Id: <5640c7e00710251014t307867actac02ea8b8094de4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570710242047h1d9b1c64k6381ba5c3a421355@mail.gmail.com>
In-Reply-To: <5bc4c4570710242047h1d9b1c64k6381ba5c3a421355@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/25/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> /* something like (but do have a look at the paraslash sources)
>     do {
>         wrote = send (socket, (const char *) buf + bytes_written,
>                              count - bytes_written, MSG_NOSIGNAL);
>     }  while (wrote < 0 && errno = EAGAIN);
> */
>
>
You can also look at iperf code, ttcp code etc.
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
