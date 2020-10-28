# ankor-docker
Тестовое задание для компании Анкор

## Build

## Run

```bash
To run bamsort: docker run -v /my/local/data:/data jeltje/biobambam bamsort inputformat=sam level=1 inputthreads= outputthreads= calmdnm=1 calmdnmrecompindetonly=1 calmdnmreference=/data/ I=/data/<input.sam> O=data/<output.bam>
```