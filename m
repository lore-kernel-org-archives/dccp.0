From: Eric Dumazet <edumazet@google.com>
Date: Fri, 03 Mar 2017 15:22:33 +0000
Subject: Re: net/dccp: use-after-free in dccp_feat_activate_values
Message-Id: <CANn89i+E+DkUJBV-3AQ38hstj9=G7=3fLJuG8LA6upp77ecwPA@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
In-Reply-To: <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Mar 3, 2017 at 7:12 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> The first bot that picked this up started spewing:
>
> BUG: spinlock recursion on CPU#1, syz-executor2/9452

Yes. The bug is not about locking the listener, but protecting fields
of struct dccp_request_sock

I will provide a patch, once I reach the office and after the breakfast ;)
