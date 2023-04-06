From: Willem de Bruijn <willemb@google.com>
Date: Thu, 06 Apr 2023 15:34:28 +0000
Subject: Re: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <CA+FuTSeKpOJVqcneCoh_4x4OuK1iE0Tr6f3rSNrQiR-OUgjWow@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Thu, Apr 6, 2023 at 10:45=E2=80=AFAM Breno Leitao <leitao@debian.org> wr=
ote:
>
> From: Breno Leitao <leit@fb.com>
>
> This patchset creates the initial plumbing for a io_uring command for
> sockets.
>
> For now, create two uring commands for sockets, SOCKET_URING_OP_SIOCOUTQ
> and SOCKET_URING_OP_SIOCINQ. They are similar to ioctl operations
> SIOCOUTQ and SIOCINQ. In fact, the code on the protocol side itself is
> heavily based on the ioctl operations.

This duplicates all the existing ioctl logic of each protocol.

Can this just call the existing proto_ops.ioctl internally and translate fr=
om/to
io_uring format as needed?
