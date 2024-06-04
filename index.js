import { ethers } from 'ethers'
import ABI from './abi.json' with { type: "json" };

const PROVIDER = new ethers.JsonRpcProvider('https://sepolia.gateway.tenderly.co');
const WALLET_PKEY = '0xb5537bcfe058b4943381b9f06e1ef47a516bd0ce2384def482883ef645444ede'
const WALLET = new ethers.Wallet(WALLET_PKEY, PROVIDER)

const CONTRACT = new ethers.Contract('0x8d4ac62a27e5360a9c4b5bd082e4a2c729f36b8c', ABI, WALLET)

const METHODS = [
    'uintToStringProvable',
    'uintToStringOZ',
    'uintToStringMikhail',
    'uintToStringSaturn',
]

const INTS = [
    0n,
    1n,
    9n,
    10n,
    99n,
    100n,
    999n,
    1000n,
    9999n,
    10000n,
    99999n,
    100000n,
    999999n,
    1000000n,
    9999999n,
    10000000n,
    99999999n,
    100000000n,
    999999999n,
    1000000000n,
    9999999999n,
    10000000000n,
    99999999999n,
    100000000000n,
    999999999999n,
    1000000000000n,
    9999999999999n,
    10000000000000n,
    99999999999999n,
    100000000000000n,
    999999999999999n,
    1000000000000000n,
    9999999999999999n,
    10000000000000000n,
    99999999999999999n,
    100000000000000000n,
    999999999999999999n,
    1000000000000000000n,
    9999999999999999999n,
    10000000000000000000n,
    99999999999999999999n,
    100000000000000000000n,
    999999999999999999999n,
    1000000000000000000000n,
    9999999999999999999999n,
    10000000000000000000000n,
    99999999999999999999999n,
    100000000000000000000000n,
    999999999999999999999999n,
    1000000000000000000000000n,
    9999999999999999999999999n,
    10000000000000000000000000n,
    99999999999999999999999999n,
    (2n ** 32n) - 1n,
    (2n ** 32n),
    (2n ** 32n) + 1n,
    (2n ** 48n) - 1n,
    (2n ** 48n),
    (2n ** 48n) + 1n,
    (2n ** 64n) - 1n,
    (2n ** 64n),
    (2n ** 64n) + 1n,
    (2n ** 128n) - 1n,
    (2n ** 128n),
    (2n ** 128n) + 1n,
    (2n ** 256n) - 1n,
]

let csv = 'algorithm,'
INTS.map(i => csv += i.toString(10) + ',')

let count = 0
for(let t = 0; t < METHODS.length; ++t) {
    let method = METHODS[t]
    csv += `\n${METHODS[t]},`
    for(let i = 0; i < INTS.length; ++i) {
        let input = INTS[i].toString(10)
        const transactionDetails = await getTransactionPropertiesViaAlchemyRPC()
        let receipt = undefined
        console.log(`\nTEST ${++count}: ${method}(${input})`)
        try {
            const transaction = await CONTRACT[method](input, transactionDetails)
            receipt = await transaction.wait()
            console.log(`    https://sepolia.etherscan.io/tx/${receipt.hash}`)
            receipt.logs.map(raw => {
                const log = CONTRACT.interface.parseLog(raw)
                if(log?.name  == "TestResult") {
                    if(log.args[0].toString(10) !== input) {
                        console.log(`    ERROR: Input value mutated. Sent ${input} but contract received ${log.args[0].toString(10)}`)
                        console.log(`    ${input} != ${log.args[0].toString(10)} ?? ${log.args[1]}`)
                        csv += 'ERROR,'
                    } else if(log.args[0].toString(10) !== log.args[1]) {
                        console.log(`    ERROR: Encoding mismatch: ${log.args[0].toString(10)} != ${log.args[1]}`)
                        console.log(`    ${input} == ${log.args[0].toString(10)} == ${log.args[1]}`)
                        csv += 'ERROR,'
                    } else {
                        console.log(`    ${input} == ${log.args[0].toString(10)} == ${log.args[1]}`)
                        console.log(`    ${log.args[2]} gas used`)
                        csv += `${log.args[2]},`
                    }
                }
            })
        } catch (err) {
            console.log(`    ERROR: Transaction failed ${method}: ${input}`)
            console.log(err)
            csv += 'EXCEPTION,'
        }
    }
}

console.log('===================================================================\n')
console.log('RESULTS:\n')
console.log(csv)
console.log()

async function getTransactionPropertiesViaAlchemyRPC() {
    let [block, priority_hex] = await Promise.all([
        await PROVIDER.getBlock('latest'),
        await PROVIDER.send('eth_maxPriorityFeePerGas', [])
    ])

    const base_fee = block.baseFeePerGas ?? 15
    const priority = BigInt(priority_hex)
    const base = BigInt((base_fee * 115n) / 100n)   //  +15% in case traffic rises

    return {
        maxPriorityFeePerGas: priority.toString(),
        maxFeePerGas: (base + priority).toString(),
    }
}
