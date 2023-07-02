From: Askar Safin <safinaskar@gmail.com>
Date: Sun, 02 Jul 2023 17:54:47 +0000
Subject: Re: [PATCH net-next v3 17/18] sock: Remove ->sendpage*() in favour of sendmsg(MSG_SPLICE_PAGES)
Message-Id: <CAPnZJGB6gk47Hw-OE2_9eSKJ0DwOzEiL+tncMJyiOD6arw6xag@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> -/* In some cases, both sendpage() and sendmsg() could have added
> - * an skb to the write queue, but failed adding payload on it.
> - * We need to remove it to consume less memory, but more
> - * importantly be able to generate EPOLLOUT for Edge Trigger epoll()
> - * users.
> +/* In some cases, both sendmsg() could have added an skb to the write queue,
> + * but failed adding payload on it.  We need to remove it to consume less
> + * memory, but more importantly be able to generate EPOLLOUT for Edge Trigger
> + * epoll() users.
>   */

There is a typo here. "Both" is redundant now

-- 
Askar Safin
