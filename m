From: Eric Dumazet <edumazet@google.com>
Date: Tue, 31 May 2022 22:04:34 +0000
Subject: Re: [PATCH net-next v1 1/2] net: Update bhash2 when socket's rcv saddr changes
Message-Id: <CANn89i+pg8guF+XeOngSMa4vUD81g=u-pCBpi0Yp2WB9PQZvdg@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, May 24, 2022 at 4:20 PM Joanne Koong <joannelkoong@gmail.com> wrote:
>
> Commit d5a42de8bdbe ("net: Add a second bind table hashed by port and
> address") added a second bind table, bhash2, that hashes by a socket's port
> and rcv address.
>
> However, there are two cases where the socket's rcv saddr can change
> after it has been binded:
>
> 1) The case where there is a bind() call on "::" (IPADDR_ANY) and then
> a connect() call. The kernel will assign the socket an address when it
> handles the connect()
>
> 2) In inet_sk_reselect_saddr(), which is called when rerouting fails
> when rebuilding the sk header (invoked by inet_sk_rebuild_header)
>
> In these two cases, we need to update the bhash2 table by removing the
> entry for the old address, and adding a new entry reflecting the updated
> address.
>
> Reported-by: syzbot+015d756bbd1f8b5c8f09@syzkaller.appspotmail.com
> Fixes: d5a42de8bdbe ("net: Add a second bind table hashed by port and address")
> Signed-off-by: Joanne Koong <joannelkoong@gmail.com>
> ---

Reviewed-by: Eric Dumazet <edumzet@google.com>
