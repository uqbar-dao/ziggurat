/+  smart=zig-sys-smart
|%
+$  signature   [p=@ux q=ship r=life]
::
+$  book  (map [town=@ux lord=id:smart salt=@] [=token-type =grain:smart])
+$  transaction-store  (map pub=@ux [sent=(map @ux [=egg:smart args=supported-args]) received=(map @ux =egg:smart)])
+$  metadata-store  (map @ asset-metadata)  ::  metadata is keyed by SALT of grains associated.
::
+$  token-type  ?(%token %nft %unknown)
::
::  TODO: move this to smart.hoon?
+$  egg-status-code
  ::  TX status codes:
  $%  %100  ::  100: transaction submitted from wallet to sequencer
      %101  ::  101: transaction received by sequencer
      %103  ::  103: failure: transaction rejected by sequencer
      errorcode:smart
  ==
::
+$  wallet-update
  $%  [%new-book tokens=(map pub=id:smart =book)]
      [%tx-status hash=@ux =egg:smart args=(unit supported-args)]
  ==
::
+$  wallet-poke
  $%  [%import-seed mnemonic=@t password=@t nick=@t]
      [%generate-hot-wallet password=@t nick=@t]
      [%derive-new-address hdpath=tape nick=@t]
      [%delete-address address=@ux]
      [%edit-nickname address=@ux nick=@t]
      [%sign-typed-message from=id:smart =typed-message:smart]
      ::  HW wallet stuff
      [%add-tracked-address address=@ux nick=@t]
      [%submit-signed hash=@ eth-hash=@ sig=[v=@ r=@ s=@]]
      ::  testing and internal
      [%set-nonce address=@ux town=id:smart new=@ud]
      [%populate seed=@ux]
      ::  TX submit pokes
      ::  if we have a private key for the 'from' address, sign. if not,
      ::  allow hardware wallet to sign on frontend and %submit-signed
      $:  %submit-custom
          from=id:smart
          to=id:smart
          town=id:smart
          gas=[rate=@ud bud=@ud]
          args=@t  ::  literally `ream`ed to form args
          my-grains=(set id:smart)
          cont-grains=(set id:smart)
      ==
      $:  %submit
          from=id:smart
          to=id:smart
          town=id:smart
          gas=[rate=@ud bud=@ud]
          args=supported-args
      ==
  ==
::
+$  supported-args
  $%  [%give salt=@ to=id:smart amount=@ud]
      [%give-nft salt=@ to=id:smart item-id=@ud]
      [%custom args=@t]
  ==
::
+$  asset-metadata
  $%  [%token token-metadata]
      [%nft nft-metadata]
  ==
+$  token-metadata
  $:  name=@t
      symbol=@t
      decimals=@ud
      supply=@ud
      cap=(unit @ud)
      mintable=?
      minters=(set id:smart)
      deployer=id:smart
      salt=@
  ==
::
+$  nft-metadata
  $:  name=@t
      symbol=@t
      attributes=(set @t)
      supply=@ud
      cap=(unit @ud)
      mintable=?
      minters=(set id:smart)
      deployer=id:smart
      salt=@
  ==
::
+$  token-account
  $:  balance=@ud
      allowances=(map sender=id:smart @ud)
      metadata=id:smart
  ==
::
+$  nft-account
  $:  metadata=id:smart
      items=(map @ud item)
      allowances=(set [id:smart @ud])
      full-allowances=(set id:smart)
  ==
+$  item
  $:  id=@ud
      data=(set [@t @t])
      desc=@t
      uri=@t
      transferrable=?
  ==
--
