// generate-angular-tests.js
const fs = require('fs')
const path = require('path')

async function generateSpec(sourceCode, fileName) {
    const isComponent = fileName.endsWith('.component.ts')
    const isService = fileName.endsWith('.service.ts')

    const context = isComponent
        ? 'This is an Angular component. Use TestBed.configureTestingModule, ComponentFixture, and test both the component class logic and template bindings where relevant.'
        : isService
            ? 'This is an Angular injectable service. Use TestBed.configureTestingModule with providers, and mock any HttpClient or dependencies using jasmine spies.'
            : 'This is an Angular TypeScript file. Use TestBed as appropriate.'

    const prompt = `Write a Jasmine unit test spec file for this Angular ${isComponent ? 'component' : isService ? 'service' : 'file'}.
${context} Only output valid jasmine test code (no markdown fences, no explanation).

File: ${fileName}
Code:${sourceCode}`

    const response = await fetch('http://localhost:11434/api/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            model: 'gemma3:4b',
            //model: 'qwen2.5-coder:7b',
            prompt,
            stream: false
        })
    })

    const data = await response.json()
    return data.response
}

async function main() {
    const targetFile = process.argv[2] // e.g. src/app/user.service.ts
    if (!targetFile) {
        console.error('Usage: node generate-angular-tests.js <path-to-ts-file>')
        process.exit(1)
    }

    const sourceCode = fs.readFileSync(targetFile, 'utf-8')
    const fileName = path.basename(targetFile)
    const specContent = await generateSpec(sourceCode, fileName)

    const specPath = targetFile.replace('.ts', '.spec.ts')
    fs.writeFileSync(specPath, specContent)
    console.log(`Generated: ${specPath}`)
}

main()