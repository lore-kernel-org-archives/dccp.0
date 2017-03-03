From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Mar 2017 15:13:04 +0000
Subject: Re: net/dccp: use-after-free in dccp_feat_activate_values
Message-Id: <1488553984.9415.332.camel@edumazet-glaptop3.roam.corp.google.com>
List-Id: <dccp.vger.kernel.org>
References: <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
In-Reply-To: <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, 2017-03-03 at 16:06 +0100, Dmitry Vyukov wrote:

> Something that compiles is definitely better :)
> Reapplied.

Just to be clear : This is not the proper patch. This only reduces the
race.

bh_lock_sock() does not prevent a user process from owning the socket.

We need another protection, probably RCU based, or another spinlock
protecting the fields needed at SYNACK generation.



