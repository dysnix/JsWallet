require! {
    \react
    \prelude-ls : { map }
    \../pin.ls : { set, check, exists, del, setbkp } 
    \../navigate.ls
    \../get-primary-info.ls
    \../get-lang.ls
    \../send-form.ls : { notify-form-result }
    \../seed.ls
    \../menu-funcs.ls
    \./choose-language.ls
    \../icons.ls
    \./confirmation.ls : { confirm }
}
.locked
    @import scheme
    padding-top: 70px
    height: $height
    height: 100vh
    box-sizing: border-box
    text-align: center
    .icon-svg
        position: relative
        height: 12px
        top: 2px
        margin-right: 3px
    .language
        position: absolute
    .password
        -webkit-text-security: disc
        text-security: disc
        &::-webkit-outer-spin-button, &::-webkit-inner-spin-button
            -webkit-appearance: none
        -moz-appearance: textfield
    >.logo 
        margin: 4rem 0
        >img
            height: 80px
            margin-bottom: 1rem
        >.title
            font-size: 12px
            font-weight: 600
            letter-spacing: 4px
            text-align: center
    >.title
        font-size: 20px
        margin-bottom: 1rem
    >.inputs
        div
            position: relative
            .division
                float: none
                margin: 15px auto 0
                overflow: hidden
                position: relative
                text-align: center
                width: 100px
                font-size: 10px
                .line
                    border-top: 1px solid rgba(223, 223, 223, 0.2)
                    position: absolute
                    top: 6px
                    width: 34%
                    &.l
                        left: 0
                    &.r
                        right: 0
        input
            text-align: center
            font-size: 17px
            display: inline-block
            height: 36px
            background: transparent
            border: 1px solid #549D90
            border-radius: $border
            outline: none
            width: 120px
            letter-spacing: 5px
            box-sizing: border-box
            &:focus
                border-color: #248295
            &:placeholder
                color: $primary + 40
    >div>.wrong
        color: red
        font-size: 15px
        padding-top: 15px
        max-width: 400px
        display: inline-block
    button.setup
        font-weight: bold
        cursor: pointer
        margin-top: 15px
        width: 120px
        height: 36px
        font-size: 10px
        text-transform: uppercase
        padding: 0px 6px
        border-radius: $border
        border: 0px
        background: transparent
        &.reset
            &:hover
                text-decoration: underline
        color: white
    .hint
        color: #f2eeee
        padding: 20px 0
        max-width: 250px
        font-size: 13px
        margin: 0 auto
    .iron
        -webkit-mask-image: linear-gradient(75deg, rgba(0, 0, 0, 0.6) 30%, #000 50%, rgba(0, 0, 0, 0.6) 70%)
        -webkit-mask-size: 50%
        animation: shine 2s infinite
    @keyframes shine
        0%
            -webkit-mask-position: right
        100%
            -webkit-mask-position: left
    .version
        letter-spacing: 1px
        font-size: 8px
        padding: 6px
        color: #89829d
        border-radius: 8px
        height: 5px
        line-height: 5px
        width: 20px
        margin: 5px auto
wrong-pin = (store)->
    store.current.pin = ""
    store.current.pin-trial += 1
    left-trials = total-trials - store.current.pin-trial
    reset-wallet store if left-trials <= 0
check-pin = (store, web3t)->
    <- set-timeout _, 100
    return if not exists!
    return wrong-pin store if not check(store.current.pin)
    store.current.pin-trial = 0
    store.current.pin = ""
    store.current.loading = yes
    navigate store, web3t, \:init
    notify-form-result \unlock, null
version = (store, web3t)->
    .version.pug #{store.version}
input = (store, web3t)->
    style = get-primary-info store
    button-primary1-style=
        border: "1px solid #{style.app.primary1}"
        color: style.app.text
        background: style.app.primary1
        width: "120px"
        height: "36px"
        margin-top: "10px"
    button-primary0-style=
        border: "0"
        color: style.app.text
        background: "transparent"
        width: "100px"
        height: "36px"
        margin-top: "0px"
    locked-style=
        color: style.app.text
        background: style.app.wallet
        border: "0"
    enter = ->
        check-pin store, web3t
    change = (e)->
        store.current.pin = e.target.value
    lang = get-lang store
    catch-key = ->
        enter! if it.key-code is 13
    reset-account = ->
        res <- confirm store, "Do you have backup word phrase of current account?"
        return if res is no
        reset-wallet store
    .pug
        input.pug.password(key="pin" style=locked-style type="password" value="#{store.current.pin}" placeholder="" on-change=change on-key-down=catch-key auto-complete="off")
        if exists!
            .pug
                button.setup.pug(on-click=enter style=button-primary1-style)
                    span.pug
                        img.icon-svg.pug(src="#{icons.enter}")
                        | #{lang.enter}
                .pug
                    .division.pug
                        .line.l.pug
                        span.pug OR
                        .line.r.pug
                    .pug
                        button.setup.pug(style=button-primary0-style on-click=reset-account) NEW ACCOUNT
reset-wallet = (store)->
    setbkp!
    del!
    seed.setbkp!
    seed.del!
    store.current.pin = ""
    store.current.pin-trial = 0
    store.current.page = 'chooseinit'
total-trials = 8
wrong-trials = (store)->
    return null if store.current.pin-trial is 0
    lang = get-lang store
    left-trials = total-trials - store.current.pin-trial
    reset-account = ->
        res <- confirm store, "Do you have backup word phrase of current account?"
        return if res is no
        reset-wallet store
    wrong-pin-text = "#{left-trials}/#{total-trials} attempts left till wallet reset to default."
    .pug
        .pug.wrong(key="wrong-trial") #{wrong-pin-text}
        .pug NOTICE! Try to restore you account from seed phrase in different browser or incognito window before you reset it
        .pug
            button.reset.setup.pug(on-click=reset-account) Reset Account
setup-button = (store, web3t)->
    lang = get-lang store
    style = get-primary-info store
    { open-language } = menu-funcs store, web3t
    setup = ->
        return alert(lang.wrong-pin-should ? 'PIN should be 4 at least 4 chars length') if store.current.pin.length < 4
        set store.current.pin
        check-pin store, web3t
    text-color=
        color: style.app.text
    button-style =
        border: "1px solid #{style.app.primary3}"
        color: style.app.text2
        background: style.app.primary3
    btn-icon =
        filter: style.app.btn-icon
    .pug(key="setup-button")
        button.setup.pug(on-click=setup style=button-style)
            span.pug
                img.icon-svg.pug(src="#{icons.key}" style=btn-icon)
                | #{lang.setup ? 'Setup'}
        .hint.p.pug(style=text-color) #{lang.pin-info ? 'Please make sure to use a pin you remember. You have 7 tries. After that, you need to restore the wallet from your 12-word recovery Phrase.'}
create-wallet = (store, web3t)->
    lang = get-lang store
    style = get-primary-info store
    create = ->
        next!
    text-color=
        color: style.app.text
    button-primary2-style=
        border: "1px solid #{style.app.primary2}"
        color: style.app.text
        background: style.app.primary2
    .pug(key="create-wallet")
        button.setup.pug(on-click=create style=button-primary2-style)
            span.pug
                img.icon-svg.pug(src="#{icons.create-wallet}")
                | #{lang.create-wallet ? 'Create Wallet'}
locked = ({ store, web3t })->
    return null if store.current.loading is yes
    lang = get-lang store
    title = 
        | not exists! => lang.setup-pin ? "Setup Password or PIN"
        | _ => lang.enter-pin ? "Enter Password"
    footer =
        | not exists! => setup-button
        | _ => wrong-trials
    info = get-primary-info store
    locked-style=
        color: info.app.text
        background-image: info.app.background-image
        background-size: "cover"
    logo-style =
        filter: info.app.filterLogo
    .pug.locked(key="locked" style=locked-style)
        .pug.logo
            img.iron.pug(style=logo-style src="#{info.branding.logo}")
            .title.pug #{info.branding.title}
            version store, web3t
        .pug.title(key="locked-title") #{title}
        .pug.inputs(key="locked-inputs")
            input store, web3t
        footer store, web3t
focus = ({ store }, cb)->
    cb null
locked.focus = focus
module.exports = locked