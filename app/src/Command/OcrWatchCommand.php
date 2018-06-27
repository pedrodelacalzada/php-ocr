<?php

namespace App\Command;

class OcrWatchCommand extends \Symfony\Component\Console\Command\Command {

    public function __construct() {
        setlocale(LC_CTYPE, "es_ES.UTF-8");
        parent::__construct();
    }

    protected function configure() {
        
        $this->setName("app:ocr")
             ->setDescription("Watch directory to ocr convertion")
             ->addArgument(
                   "watch_dir", 
                   \Symfony\Component\Console\Input\InputArgument::REQUIRED,
                   "Directory to watch documents"
               );
    }

    protected function execute(\Symfony\Component\Console\Input\InputInterface $input,
            \Symfony\Component\Console\Output\OutputInterface $output) {
        
        $output->writeln("app:ocr:init");
        $watchDir = $input->getArgument("watch_dir");
        if (!is_dir($watchDir)) {
            mkdir($watchDir, $mode = 0777, true);
        }
        $fd = inotify_init();
        $watchDescriptor = inotify_add_watch($fd, $watchDir, IN_CLOSE_WRITE);
        $output->writeln("app:ocr:watch");
        
        while (true) {
            $events = inotify_read($fd);
            foreach ($events as $event) {
                $sourceFilename = $event["name"];
                $output->writeln("app:ocr:fileadded - {$sourceFilename}");
                $fileExtension = strtolower(pathinfo($sourceFilename, PATHINFO_EXTENSION));
                $pdfFilename = pathinfo($sourceFilename, PATHINFO_FILENAME);

                if (preg_match("#_ocr_#", $pdfFilename)) {
                    $output->writeln("app:ocr:fileskip - {$sourceFilename}");
                    continue;
                }
                $output->writeln("app:ocr:fileparsing - {$sourceFilename}");
                $sourcePath = "{$watchDir}/{$sourceFilename}";
                $sourcePathEscaped = escapeshellarg($sourcePath);
                $currentDate = new \DateTime();
                $currentDateString = $currentDate->format("d-m-Y_H-i-s");
                $targetPath = "{$watchDir}/{$pdfFilename}_ocr_{$currentDateString}";
                $targetPathEscaped = escapeshellarg($targetPath);

                $command = "";

                if (in_array($fileExtension, ["jpg", "png"])) {
                    $command = "tesseract -l eng+spa {$sourcePathEscaped} {$targetPathEscaped} pdf";
                } 
                elseif (in_array($fileExtension, ["pdf"])) {
                    $command = "pdfsandwich -rgb -lang eng+spa {$sourcePathEscaped} -o {$targetPathEscaped}.pdf";
                }

                if (!empty($command)) {
                    $output->writeln("app:ocr:running - {$command}");
                    passthru($command);
                    passthru("chmod 777 {$targetPathEscaped}.pdf");
                    unlink($sourcePath);
                }
            }
            sleep(2);
        }
    }
}
    