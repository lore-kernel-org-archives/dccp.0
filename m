From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Date: Thu, 01 Nov 2007 17:28:58 +0000
Subject: Re: DCCP and GStreamer: File descriptor sharing
Message-Id: <20071101172858.GH13130@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570711010726h5580c72dt59748c57be50b064@mail.gmail.com>
In-Reply-To: <5bc4c4570711010726h5580c72dt59748c57be50b064@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Em Thu, Nov 01, 2007 at 11:26:10AM -0300, =C5=81eandro Sales escreveu:
> Hi all,
>    I want to share a same socket-fd between two process using dccp.
> The gstreamer plugin architecture uses a concept of sink and src (each
> one named element), where sink send and src receive data. In this
> case, one of then connects and inform the file descriptor to the
> other. Then I thought that if I just share the socket_fd the things
> will work, but it didn't. I need something like this:
>=20
> On dccp_server_sink_element:
>=20
> 1 - sock_fd =3D socket(...);  // sock_id =3D 10 (for instance), sink tell
> dccp_server_src_element this value
> 2 - bind(sock_fd);
> 3 - listen(sock_fd);
>=20
> On dccp_server_src_element:
>=20
> 1 - sock_fd =3D 10 // for the first version I will just pass this value
> via set property, but after I will use unix_socket (as suggested by
> Arnaldo) to communicate both elements

You _have_ to use unix sockets to pass the fd. fd 10 on one process has
absolutely nothing to do with fd 10 on another process, only if both
were created by the same parent, but from your description it doesn't
seems to be the case.

- Arnaldo
